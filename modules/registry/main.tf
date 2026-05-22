locals {
  name_prefix = "${var.name_prefix}-${var.environment}"
  # ACR names: alphanumeric only, 5-50 chars
  acr_name = replace("${var.name_prefix}${var.environment}acr", "-", "")
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# ── Azure Container Registry ──────────────────────────────────────────────────

resource "azurerm_container_registry" "main" {
  name                = local.acr_name
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  sku                 = var.acr_sku

  # Admin account disabled — use Managed Identity for pull/push
  admin_enabled = false

  # Geo-replication for production (Standard/Premium only)
  dynamic "georeplications" {
    for_each = var.geo_replication_regions
    content {
      location                  = georeplications.value
      zone_redundancy_enabled   = false
      tags                      = {}
    }
  }

  # Retention policy for untagged manifests (Premium only)
  dynamic "retention_policy" {
    for_each = var.acr_sku == "Premium" ? [1] : []
    content {
      days    = var.untagged_retention_days
      enabled = true
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }
}

# Grant AcrPull to the Container Apps managed identity
resource "azurerm_role_assignment" "acr_pull" {
  count                = var.container_apps_identity_principal_id != null ? 1 : 0
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = var.container_apps_identity_principal_id
}

# Grant AcrPush to the build-engine managed identity
resource "azurerm_role_assignment" "acr_push" {
  count                = var.build_engine_identity_principal_id != null ? 1 : 0
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPush"
  principal_id         = var.build_engine_identity_principal_id
}

# ── Azure Service Bus (replaces AWS SQS) ─────────────────────────────────────

resource "azurerm_service_bus_namespace" "main" {
  name                = "${local.name_prefix}-sb"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard" # Standard has DLQ support; Basic does not

  # Minimum TLS version
  minimum_tls_version = "1.2"

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }
}

resource "azurerm_service_bus_queue" "builds" {
  name         = "builds"
  namespace_id = azurerm_service_bus_namespace.main.id

  # 30-minute lock for long builds; renew via API
  lock_duration = "PT5M" # Max 5 min per lock; build-engine renews automatically

  # Max delivery attempts before DLQ
  max_delivery_count = 3

  # Message TTL — builds older than 24h are expired
  default_message_time_to_live = "P1D"

  # Dead-letter queue — keeps failed build requests for inspection
  dead_lettering_on_message_expiration = true

  # Message size: 256 KB (Standard tier max)
  max_size_in_megabytes = 1024
}

resource "azurerm_service_bus_queue" "builds_dlq_forward" {
  # Separate queue for manual reprocessing of DLQ'd builds
  name         = "builds-replay"
  namespace_id = azurerm_service_bus_namespace.main.id

  lock_duration                        = "PT5M"
  max_delivery_count                   = 1
  default_message_time_to_live         = "P7D"
  dead_lettering_on_message_expiration = false
  max_size_in_megabytes                = 1024
}

# ── Shared Access Policy for build-engine (Send + Listen on builds queue) ────

resource "azurerm_servicebus_queue_authorization_rule" "build_engine" {
  name     = "build-engine"
  queue_id = azurerm_service_bus_queue.builds.id

  listen = true
  send   = false
  manage = false
}

resource "azurerm_servicebus_queue_authorization_rule" "platform_api" {
  name     = "platform-api"
  queue_id = azurerm_service_bus_queue.builds.id

  listen = false
  send   = true
  manage = false
}

# ── Store Service Bus connection strings in Key Vault ─────────────────────────

resource "azurerm_key_vault_secret" "sb_build_engine_conn" {
  name         = "${local.name_prefix}-sb-build-engine-conn"
  value        = azurerm_servicebus_queue_authorization_rule.build_engine.primary_connection_string
  key_vault_id = var.key_vault_id

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "azurerm_key_vault_secret" "sb_platform_api_conn" {
  name         = "${local.name_prefix}-sb-platform-api-conn"
  value        = azurerm_servicebus_queue_authorization_rule.platform_api.primary_connection_string
  key_vault_id = var.key_vault_id

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
