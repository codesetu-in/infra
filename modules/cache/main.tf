locals {
  name_prefix = "${var.name_prefix}-${var.environment}"
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# ── Random auth key for Redis ─────────────────────────────────────────────────
# Azure Cache for Redis generates an access key automatically; we store it in Key Vault.

# ── Azure Cache for Redis ─────────────────────────────────────────────────────

resource "azurerm_redis_cache" "main" {
  name                = "${local.name_prefix}-redis"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name

  sku_name = var.sku_name
  family   = var.sku_family
  capacity = var.capacity

  # TLS-only — Redis port 6379 is disabled
  non_ssl_port_enabled     = false
  minimum_tls_version      = "1.2"
  redis_version            = var.redis_version

  # Enable data persistence for Standard/Premium tiers
  dynamic "redis_configuration" {
    for_each = [1]
    content {
      maxmemory_policy = var.maxmemory_policy
      # Enable AOF persistence for Standard+ (Basic doesn't support it)
      aof_backup_enabled            = var.sku_name != "Basic" ? true : false
      aof_storage_connection_string_0 = var.sku_name != "Basic" ? var.persistence_connection_string : null
    }
  }

  # Private endpoint is managed separately — no public network disable here for Basic tier
  public_network_access_enabled = var.enable_private_endpoint ? false : true

  # Basic tier: no patch window config needed
  dynamic "patch_schedule" {
    for_each = var.sku_name != "Basic" ? [1] : []
    content {
      day_of_week    = "Sunday"
      start_hour_utc = 2
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }
}

# ── Private Endpoint (production only) ───────────────────────────────────────

resource "azurerm_private_endpoint" "redis" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${local.name_prefix}-redis-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${local.name_prefix}-redis-psc"
    private_connection_resource_id = azurerm_redis_cache.main.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.redis_private_dns_zone_id != null ? [1] : []
    content {
      name                 = "redis-dns-zone-group"
      private_dns_zone_ids = [var.redis_private_dns_zone_id]
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }
}

# ── Store connection string in Key Vault ──────────────────────────────────────

resource "azurerm_key_vault_secret" "redis_url" {
  name         = "${local.name_prefix}-redis-url"
  value        = "rediss://:${azurerm_redis_cache.main.primary_access_key}@${azurerm_redis_cache.main.hostname}:${azurerm_redis_cache.main.ssl_port}"
  key_vault_id = var.key_vault_id

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "azurerm_key_vault_secret" "redis_key" {
  name         = "${local.name_prefix}-redis-key"
  value        = azurerm_redis_cache.main.primary_access_key
  key_vault_id = var.key_vault_id

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
