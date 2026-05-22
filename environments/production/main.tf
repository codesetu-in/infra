terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

locals {
  environment  = "production"
  name_prefix  = "deploycloud"
  domain_name  = "deploycloud.app"
  azure_region = "eastus"
}

# ── Networking ────────────────────────────────────────────────────────────────

module "networking" {
  source = "../../modules/networking"

  name_prefix  = local.name_prefix
  environment  = local.environment
  azure_region = local.azure_region

  vnet_cidr                    = "10.0.0.0/16"
  container_apps_subnet_cidr   = "10.0.0.0/23"
  database_subnet_cidr         = "10.0.4.0/24"
  private_endpoint_subnet_cidr = "10.0.5.0/24"
}

# ── Container Apps + Key Vault ────────────────────────────────────────────────

module "container_apps" {
  source = "../../modules/container-apps"

  name_prefix              = local.name_prefix
  environment              = local.environment
  resource_group_name      = module.networking.resource_group_name
  container_apps_subnet_id = module.networking.container_apps_subnet_id

  acr_login_server   = module.registry.acr_login_server
  log_retention_days = 90

  # Production: always have at least 1 replica, scale up aggressively
  api_min_replicas       = 1
  api_max_replicas       = 20
  api_cpu                = 1.0
  api_memory             = "2Gi"
  dashboard_min_replicas = 1
  dashboard_max_replicas = 5
  dashboard_cpu          = 0.5
  dashboard_memory       = "1Gi"

  api_environment_variables = {
    NODE_ENV   = "production"
    APP_DOMAIN = local.domain_name
    PORT       = "3001"
    AZURE_CLIENT_ID = module.container_apps.platform_identity_client_id
  }

  api_secret_refs = {
    DATABASE_URL         = "db-url"
    REDIS_URL            = "redis-url"
    SB_PLATFORM_API_CONN = "sb-platform-api-conn"
  }

  api_key_vault_secrets = {
    db-url               = "${module.container_apps.key_vault_uri}secrets/${local.name_prefix}-${local.environment}-pg-url"
    redis-url            = "${module.container_apps.key_vault_uri}secrets/${local.name_prefix}-${local.environment}-redis-url"
    sb-platform-api-conn = "${module.container_apps.key_vault_uri}secrets/${local.name_prefix}-${local.environment}-sb-platform-api-conn"
  }
}

# ── Registry (ACR Standard + Service Bus) ────────────────────────────────────

module "registry" {
  source = "../../modules/registry"

  name_prefix         = local.name_prefix
  environment         = local.environment
  resource_group_name = module.networking.resource_group_name
  key_vault_id        = module.container_apps.key_vault_id

  acr_sku = "Standard" # ~$20/mo; supports geo-replication + content trust
  container_apps_identity_principal_id = module.container_apps.platform_identity_principal_id
}

# ── Database (PostgreSQL — production sizing) ─────────────────────────────────

module "database" {
  source = "../../modules/database"

  name_prefix         = local.name_prefix
  environment         = local.environment
  resource_group_name = module.networking.resource_group_name
  database_subnet_id  = module.networking.database_subnet_id
  key_vault_id        = module.container_apps.key_vault_id

  pg_version                = "16"
  sku_name                  = "GP_Standard_D2s_v3" # ~$120/mo, general purpose
  storage_mb                = 65536                # 64 GB
  backup_retention_days     = 7
  geo_redundant_backup      = true
  high_availability_enabled = true
}

# ── Cache (Standard C1 with HA) ───────────────────────────────────────────────

module "cache" {
  source = "../../modules/cache"

  name_prefix         = local.name_prefix
  environment         = local.environment
  resource_group_name = module.networking.resource_group_name
  key_vault_id        = module.container_apps.key_vault_id

  sku_name   = "Standard" # ~$90/mo with replication
  sku_family = "C"
  capacity   = 1          # 1 GB

  # Private endpoint for production — Redis only accessible from within VNet
  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  redis_private_dns_zone_id  = module.networking.redis_private_dns_zone_id
}

# ── DNS ───────────────────────────────────────────────────────────────────────

module "dns" {
  source = "../../modules/dns"

  name_prefix         = local.name_prefix
  environment         = local.environment
  resource_group_name = module.networking.resource_group_name
  domain_name         = local.domain_name
  create_zone         = true

  container_apps_default_domain = module.container_apps.environment_default_domain
  custom_domain_verification_id = null
}

# ── CDN / WAF (Azure Front Door Standard) ────────────────────────────────────
# ~$35/mo base. Skip in staging; use Cloudflare free tier as an alternative.

module "cdn" {
  source = "../../modules/cdn"

  name_prefix         = local.name_prefix
  environment         = local.environment
  resource_group_name = module.networking.resource_group_name
  api_fqdn            = module.container_apps.api_fqdn
  domain_name         = local.domain_name
  waf_rate_limit      = 2000
}

# ── Monitoring ────────────────────────────────────────────────────────────────

module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix         = local.name_prefix
  environment         = local.environment
  resource_group_name = module.networking.resource_group_name
  alerts_email        = var.alerts_email

  container_app_api_id = module.container_apps.platform_identity_id
  postgres_server_id   = module.database.server_id
  cpu_alarm_threshold  = 80
  error_rate_threshold = 5
}
