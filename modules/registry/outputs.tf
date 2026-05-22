output "acr_id" {
  description = "Azure Container Registry resource ID"
  value       = azurerm_container_registry.main.id
}

output "acr_name" {
  description = "Azure Container Registry name"
  value       = azurerm_container_registry.main.name
}

output "acr_login_server" {
  description = "ACR login server (e.g. deploycloud.azurecr.io)"
  value       = azurerm_container_registry.main.login_server
}

output "service_bus_namespace_id" {
  description = "Service Bus Namespace resource ID"
  value       = azurerm_servicebus_namespace.main.id
}

output "service_bus_namespace_name" {
  description = "Service Bus Namespace name"
  value       = azurerm_servicebus_namespace.main.name
}

output "builds_queue_name" {
  description = "Name of the builds Service Bus queue"
  value       = azurerm_servicebus_queue.builds.name
}

output "sb_build_engine_conn_secret_name" {
  description = "Key Vault secret name for the build-engine Service Bus connection string"
  value       = azurerm_key_vault_secret.sb_build_engine_conn.name
}

output "sb_platform_api_conn_secret_name" {
  description = "Key Vault secret name for the platform-api Service Bus connection string"
  value       = azurerm_key_vault_secret.sb_platform_api_conn.name
}
