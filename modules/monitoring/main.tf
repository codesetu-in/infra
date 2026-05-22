locals {
  name_prefix = "${var.name_prefix}-${var.environment}"
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# ── Action Group (email alerts) ───────────────────────────────────────────────

resource "azurerm_monitor_action_group" "email" {
  name                = "${local.name_prefix}-alerts-ag"
  resource_group_name = var.resource_group_name
  short_name          = "dc-alerts"

  email_receiver {
    name                    = "platform-team"
    email_address           = var.alerts_email
    use_common_alert_schema = true
  }

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }
}

# ── Container App CPU alert ───────────────────────────────────────────────────

resource "azurerm_monitor_metric_alert" "api_cpu" {
  name                = "${local.name_prefix}-api-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.container_app_api_id]
  description         = "Platform API CPU utilization is above ${var.cpu_alarm_threshold}%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "CpuUsage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_alarm_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── Container App memory alert ────────────────────────────────────────────────

resource "azurerm_monitor_metric_alert" "api_memory" {
  name                = "${local.name_prefix}-api-memory-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.container_app_api_id]
  description         = "Platform API memory utilization is above 85%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "MemoryUsage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── HTTP 5xx error rate alert ─────────────────────────────────────────────────

resource "azurerm_monitor_metric_alert" "api_5xx" {
  name                = "${local.name_prefix}-api-5xx-rate"
  resource_group_name = var.resource_group_name
  scopes              = [var.container_app_api_id]
  description         = "Platform API 5xx error rate is elevated"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "Requests"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.error_rate_threshold

    dimension {
      name     = "statusCodeCategory"
      operator = "Include"
      values   = ["5xx"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── PostgreSQL storage alert ──────────────────────────────────────────────────

resource "azurerm_monitor_metric_alert" "db_storage" {
  count               = var.postgres_server_id != null ? 1 : 0
  name                = "${local.name_prefix}-db-storage-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.postgres_server_id]
  description         = "PostgreSQL storage utilization is above 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
