locals {
  name_prefix = "${var.name_prefix}-${var.environment}"
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# ── Random password for PostgreSQL admin ──────────────────────────────────────

resource "random_password" "postgres_admin" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_upper        = 4
  min_lower        = 4
  min_numeric      = 4
}

# ── Private DNS Zone for PostgreSQL (created in networking module) ────────────

data "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

# ── PostgreSQL Flexible Server ────────────────────────────────────────────────

resource "azurerm_postgresql_flexible_server" "main" {
  name                = "${local.name_prefix}-pg"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location

  version    = var.pg_version
  sku_name   = var.sku_name

  administrator_login    = "deployadmin"
  administrator_password = random_password.postgres_admin.result

  # VNet injection via delegated subnet — no public internet access
  delegated_subnet_id    = var.database_subnet_id
  private_dns_zone_id    = data.azurerm_private_dns_zone.postgres.id

  storage_mb                   = var.storage_mb
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup

  # High availability for production
  dynamic "high_availability" {
    for_each = var.high_availability_enabled ? [1] : []
    content {
      mode = "ZoneRedundant"
    }
  }

  # Auto-grow storage when running low
  auto_grow_enabled = true

  # Maintenance window (Sunday 02:00 UTC)
  maintenance_window {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }

  lifecycle {
    ignore_changes = [
      # Allow manual password rotation without triggering replacement
      administrator_password,
      zone,
      high_availability[0].standby_availability_zone,
    ]
  }

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }

  depends_on = [data.azurerm_private_dns_zone.postgres]
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# ── PostgreSQL server parameters ──────────────────────────────────────────────

resource "azurerm_postgresql_flexible_server_configuration" "log_min_duration_statement" {
  name      = "log_min_duration_statement"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "5000" # log queries over 5 seconds
}

resource "azurerm_postgresql_flexible_server_configuration" "connection_throttling" {
  name      = "connection_throttle.enable"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "on"
}

# ── Store credentials in Key Vault ────────────────────────────────────────────

resource "azurerm_key_vault_secret" "postgres_url" {
  name         = "${local.name_prefix}-pg-url"
  value        = "postgresql://deployadmin:${random_password.postgres_admin.result}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${var.database_name}?sslmode=require"
  key_vault_id = var.key_vault_id

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "${local.name_prefix}-pg-password"
  value        = random_password.postgres_admin.result
  key_vault_id = var.key_vault_id

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
