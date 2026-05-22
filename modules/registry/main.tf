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
  admin_enabled       = false

  # Geo-replication for Standard/Premium tiers
  dynamic "georeplications" {
    for_each = var.geo_replication_regions
    content {
      location                = georeplications.value
      zone_redundancy_enabled = false
      tags                    = {}
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
# Note: azurerm uses "servicebus" (no underscore) for Service Bus resource types.

resource "azurerm_servicebus_namespace" "main" {
  name                = "${local.name_prefix}-sb"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard" # Standard has DLQ support; Basic does not
  minimum_tls_version = "1.2"

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }
}

resource "azurerm_servicebus_queue" "builds" {
  name         = "builds"
  namespace_id = azurerm_servicebus_namespace.main.id

  lock_duration                        = "PT5M"
  max_delivery_count                   = 3
  dead_lettering_on_message_expiration = true
  max_size_in_megabytes                = 1024
}

resource "azurerm_servicebus_queue" "builds_dlq_forward" {
  name         = "builds-replay"
  namespace_id = azurerm_servicebus_namespace.main.id

  lock_duration                        = "PT5M"
  max_delivery_count                   = 1
  dead_lettering_on_message_expiration = false
  max_size_in_megabytes                = 1024
}

# ── Shared Access Policies ────────────────────────────────────────────────────

resource "azurerm_servicebus_queue_authorization_rule" "build_engine" {
  name     = "build-engine"
  queue_id = azurerm_servicebus_queue.builds.id

  listen = true
  send   = false
  manage = false
}

resource "azurerm_servicebus_queue_authorization_rule" "platform_api" {
  name     = "platform-api"
  queue_id = azurerm_servicebus_queue.builds.id

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
