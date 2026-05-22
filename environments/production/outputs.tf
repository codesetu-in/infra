output "resource_group_name" {
  description = "Production resource group name"
  value       = module.networking.resource_group_name
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = module.networking.vnet_id
}

output "container_apps_environment_name" {
  description = "Container Apps Environment name"
  value       = module.container_apps.environment_name
}

output "api_fqdn" {
  description = "Platform API Container App FQDN"
  value       = module.container_apps.api_fqdn
}

output "dashboard_fqdn" {
  description = "Platform Dashboard Container App FQDN"
  value       = module.container_apps.dashboard_fqdn
}

output "acr_login_server" {
  description = "ACR login server for CI/CD image push"
  value       = module.registry.acr_login_server
}

output "acr_name" {
  description = "ACR registry name"
  value       = module.registry.acr_name
}

output "key_vault_uri" {
  description = "Key Vault vault URI"
  value       = module.container_apps.key_vault_uri
}

output "platform_identity_client_id" {
  description = "Managed identity client ID — set as AZURE_CLIENT_ID in production GitHub Environment secrets"
  value       = module.container_apps.platform_identity_client_id
}

output "database_fqdn" {
  description = "PostgreSQL Flexible Server FQDN"
  value       = module.database.fqdn
  sensitive   = true
}

output "redis_hostname" {
  description = "Azure Cache for Redis hostname"
  value       = module.cache.hostname
  sensitive   = true
}

output "dns_name_servers" {
  description = "Azure DNS zone name servers — update your domain registrar with these"
  value       = module.dns.name_servers
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace resource ID"
  value       = module.container_apps.log_analytics_workspace_id
}

output "frontdoor_endpoint_fqdn" {
  description = "Azure Front Door endpoint FQDN (production CDN/WAF ingress)"
  value       = module.cdn.frontdoor_endpoint_fqdn
}

output "frontdoor_profile_id" {
  description = "Azure Front Door profile resource ID"
  value       = module.cdn.frontdoor_profile_id
}
