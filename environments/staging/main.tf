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
      purge_soft_delete_on_destroy    = true  # allow fast teardown in staging
      recover_soft_deleted_key_vaults = true
    }
  }
}

locals {
  environment = "staging"
  name_prefix = "deploycloud"
  domain_name = "staging.deploycloud.app"
  azure_region = "eastus"
}

# ── Networking ────────────────────────────────────────────────────────────────

module "networking" {
  source = "../../modules/networking"

  name_prefix  = local.name_prefix
  environment  = local.environment
  azure_region = local.azure_region

  vnet_cidr                    = "10.1.0.0/16"
  container_apps_subnet_cidr   = "10.1.0.0/23"
  database_subnet_cidr         = "10.1.4.0/24"
  private_endpoint_subnet_cidr = "10.1.5.0/24"
}

# ── Container Apps + Key Vault ────────────────────────────────────────────────
# Creates: Container Apps Environment, platform API & dashboard apps, Key Vault,
# Log Analytics, and managed identity.

module "container_apps" {
  source = "../../modules/container-apps"

  name_prefix              = local.name_prefix
  environment              = local.environment
  resource_group_name      = module.networking.resource_group_name
  container_apps_subnet_id = module.networking.container_apps_subnet_id
  key_vault_id             = module.container_apps.key_vault_id  # self-reference resolved on second apply

  acr_login_server = module.registry.acr_login_server
  log_retention_days = 30

  # Staging: scale-to-zero (free when idle)
  api_min_replicas       = 0
  api_max_replicas       = 3
  api_cpu                = 0.5
  api_memory             = "1Gi"
  dashboard_min_replicas = 0
  dashboard_max_replicas = 2
  dashboard_cpu          = 0.5
  dashboard_memory       = "1Gi"

  api_environment_variables = {
    NODE_ENV   = "staging"
    APP_DOMAIN = local.domain_name
    PORT       = "3001"
    AZURE_CLIENT_ID = module.container_apps.platform_identity_client_id
  }

  # Secrets are referenced from Key Vault via the managed identity
  api_secret_refs = {
    DATABASE_URL = "db-url"
    REDIS_URL    = "redis-url"
    SB_PLATFORM_API_CONN = "sb-platform-api-conn"
  }

  api_key_vault_secrets = {
    db-url               = "${module.container_apps.key_vault_uri}secrets/${local.name_prefix}-${local.environment}-pg-url"
    redis-url            = "${module.container_apps.key_vault_uri}secrets/${local.name_prefix}-${local.environment}-redis-url"
    sb-platform-api-conn = "${module.container_apps.key_vault_uri}secrets/${local.name_prefix}-${local.environment}-sb-platform-api-conn"
  }
}

# ── Registry (ACR + Service Bus) ─────────────────────────────────────────────

module "registry" {
  source = "../../modules/registry"

  name_prefix         = local.name_prefix
  environment         = local.environment
  resource_group_name = module.networking.resource_group_name
  key_vault_id        = module.container_apps.key_vault_id

  acr_sku = "Basic" # ~$5/mo; upgrade to Standard for geo-replication

  container_apps_identity_principal_id = module.container_apps.platform_identity_principal_id
}

# ── Database (PostgreSQL Flexible Server) ─────────────────────────────────────

module "database" {
  source = "../../modules/database"

  name_prefix         = local.name_prefix
  environment         = local.environment
  resource_group_name = module.networking.resource_group_name
  database_subnet_id  = module.networking.database_subnet_id
  key_vault_id        = module.container_apps.key_vault_id

  pg_version            = "16"
  sku_name              = "B_Standard_B1ms" # ~$15/mo, burstable
  storage_mb            = 32768
  backup_retention_days = 7
  geo_redundant_backup  = false
  high_availability_enabled = false
}

# ── Cache (Azure Cache for Redis) ─────────────────────────────────────────────

module "cache" {
  source = "../../modules/cache"

  name_prefix         = local.name_prefix
  environment         = local.environment
  resource_group_name = module.networking.resource_group_name
  key_vault_id        = module.container_apps.key_vault_id

  sku_name   = "Basic"  # ~$16/mo, 250 MB, no HA — fine for staging
  sku_family = "C"
  capacity   = 0

  # No private endpoint in staging — uses TLS + auth over public internet
  enable_private_endpoint = false
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
  custom_domain_verification_id = null # set after Container Apps environment is created
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
  cpu_alarm_threshold  = 85
  error_rate_threshold = 20
}
