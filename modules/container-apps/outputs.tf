output "environment_id" {
  description = "Container Apps Environment resource ID"
  value       = azurerm_container_app_environment.main.id
}

output "environment_name" {
  description = "Container Apps Environment name"
  value       = azurerm_container_app_environment.main.name
}

output "environment_default_domain" {
  description = "Default domain for apps in this environment"
  value       = azurerm_container_app_environment.main.default_domain
}

output "api_fqdn" {
  description = "Fully qualified domain name of the platform API Container App"
  value       = azurerm_container_app.api.ingress[0].fqdn
}

output "dashboard_fqdn" {
  description = "Fully qualified domain name of the dashboard Container App"
  value       = azurerm_container_app.dashboard.ingress[0].fqdn
}

output "platform_identity_id" {
  description = "User-assigned managed identity resource ID"
  value       = azurerm_user_assigned_identity.platform.id
}

output "platform_identity_principal_id" {
  description = "Principal ID of the platform managed identity (for RBAC assignments)"
  value       = azurerm_user_assigned_identity.platform.principal_id
}

output "platform_identity_client_id" {
  description = "Client ID of the platform managed identity (for workload identity in apps)"
  value       = azurerm_user_assigned_identity.platform.client_id
}

output "key_vault_id" {
  description = "Key Vault resource ID for this environment"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "Key Vault vault URI"
  value       = azurerm_key_vault.main.vault_uri
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace resource ID"
  value       = azurerm_log_analytics_workspace.main.id
}
