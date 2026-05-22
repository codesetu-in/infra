output "server_id" {
  description = "PostgreSQL Flexible Server resource ID"
  value       = azurerm_postgresql_flexible_server.main.id
}

output "fqdn" {
  description = "Fully qualified domain name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "database_name" {
  description = "Name of the created database"
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "connection_url_secret_id" {
  description = "Key Vault secret ID containing the PostgreSQL connection URL"
  value       = azurerm_key_vault_secret.postgres_url.id
}

output "connection_url_secret_name" {
  description = "Key Vault secret name for the PostgreSQL connection URL"
  value       = azurerm_key_vault_secret.postgres_url.name
}
