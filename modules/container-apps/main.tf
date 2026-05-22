locals {
  name_prefix = "${var.name_prefix}-${var.environment}"
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

# ── Managed Identity for platform services ────────────────────────────────────
# Replaces AWS IAM roles — no static credentials needed.

resource "azurerm_user_assigned_identity" "platform" {
  name                = "${local.name_prefix}-platform-id"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }
}

# ── Key Vault access for managed identity ─────────────────────────────────────

resource "azurerm_key_vault_access_policy" "platform" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.platform.principal_id

  secret_permissions = ["Get", "List"]
}

# ── Log Analytics Workspace (required by Container Apps Environment) ──────────

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.name_prefix}-law"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }
}

# ── Container Apps Environment ────────────────────────────────────────────────
# Replaces ECS cluster + ALB. Handles TLS, scaling, and ingress natively.

resource "azurerm_container_app_environment" "main" {
  name                       = "${local.name_prefix}-cae"
  location                   = data.azurerm_resource_group.main.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  # VNet injection — Container Apps run inside the private subnet
  infrastructure_subnet_id       = var.container_apps_subnet_id
  internal_load_balancer_enabled = false # External = public HTTPS ingress

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }
}

# ── Platform API Container App ─────────────────────────────────────────────────

resource "azurerm_container_app" "api" {
  name                         = "${local.name_prefix}-api"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.platform.id]
  }

  template {
    min_replicas = var.api_min_replicas
    max_replicas = var.api_max_replicas

    container {
      name   = "api"
      image  = "${var.acr_login_server}/${var.api_image_name}:${var.api_image_tag}"
      cpu    = var.api_cpu
      memory = var.api_memory

      # Environment variables injected from Key Vault via managed identity
      dynamic "env" {
        for_each = var.api_environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      # Secrets fetched from Key Vault — referenced by secret name below
      dynamic "env" {
        for_each = var.api_secret_refs
        content {
          name        = env.key
          secret_name = env.value
        }
      }

      liveness_probe {
        transport = "HTTP"
        path      = var.health_check_path
        port      = var.api_port

        initial_delay           = 15
        period_seconds          = 30
        failure_count_threshold = 3
      }

      readiness_probe {
        transport = "HTTP"
        path      = var.health_check_path
        port      = var.api_port

        period_seconds          = 10
        failure_count_threshold = 3
      }
    }

    # Scale rules: HTTP-based autoscaling
    http_scale_rule {
      name                = "http-scale"
      concurrent_requests = 100
    }
  }

  # Secrets pulled from Key Vault — container references these by name
  dynamic "secret" {
    for_each = var.api_key_vault_secrets
    content {
      name                = secret.key
      key_vault_secret_id = secret.value
      identity            = azurerm_user_assigned_identity.platform.id
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = var.api_port

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.platform.id
  }

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }
}

# ── Platform Dashboard Container App ─────────────────────────────────────────

resource "azurerm_container_app" "dashboard" {
  name                         = "${local.name_prefix}-dashboard"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.platform.id]
  }

  template {
    min_replicas = var.dashboard_min_replicas
    max_replicas = var.dashboard_max_replicas

    container {
      name   = "dashboard"
      image  = "${var.acr_login_server}/${var.dashboard_image_name}:${var.dashboard_image_tag}"
      cpu    = var.dashboard_cpu
      memory = var.dashboard_memory

      dynamic "env" {
        for_each = var.dashboard_environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      liveness_probe {
        transport = "HTTP"
        path      = "/api/health"
        port      = 3000

        initial_delay           = 20
        period_seconds          = 30
        failure_count_threshold = 3
      }
    }

    http_scale_rule {
      name                = "http-scale"
      concurrent_requests = 50
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 3000

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.platform.id
  }

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }
}

# ── Key Vault for platform environment ───────────────────────────────────────

resource "azurerm_key_vault" "main" {
  name                = "${local.name_prefix}-kv"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled   = var.environment == "production"
  soft_delete_retention_days = 7

  # Operator access (for running Terraform and manual secret management)
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
    key_permissions    = ["Get", "List", "Create", "Delete", "Purge"]
  }

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }
}
