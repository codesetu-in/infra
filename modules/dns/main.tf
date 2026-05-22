# ── Azure DNS Zone ────────────────────────────────────────────────────────────

resource "azurerm_dns_zone" "main" {
  count               = var.create_zone ? 1 : 0
  name                = var.domain_name
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "terraform"
  }
}

data "azurerm_dns_zone" "main" {
  count               = var.create_zone ? 0 : 1
  name                = var.domain_name
  resource_group_name = var.resource_group_name
}

locals {
  zone_name = var.create_zone ? azurerm_dns_zone.main[0].name : data.azurerm_dns_zone.main[0].name
  zone_id   = var.create_zone ? azurerm_dns_zone.main[0].id : data.azurerm_dns_zone.main[0].id
}

# ── Wildcard CNAME → Container Apps Environment default domain ────────────────
# Apps get a URL like myapp.{default_domain}; the wildcard CNAME maps
# *.deploycloud.app → the Container Apps environment ingress.

resource "azurerm_dns_cname_record" "wildcard" {
  name                = "*"
  zone_name           = local.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = var.container_apps_default_domain

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "azurerm_dns_cname_record" "apex_www" {
  name                = "www"
  zone_name           = local.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = var.container_apps_default_domain

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── TXT verification record for Container Apps custom domain ──────────────────
# Azure Container Apps requires a TXT record for custom domain ownership verification.

resource "azurerm_dns_txt_record" "aca_verification" {
  count               = var.custom_domain_verification_id != null ? 1 : 0
  name                = "asuid"
  zone_name           = local.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300

  record {
    value = var.custom_domain_verification_id
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
