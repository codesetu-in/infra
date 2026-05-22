output "redis_id" {
  description = "Azure Cache for Redis resource ID"
  value       = azurerm_redis_cache.main.id
}

output "hostname" {
  description = "Redis hostname"
  value       = azurerm_redis_cache.main.hostname
}

output "ssl_port" {
  description = "Redis SSL port (TLS)"
  value       = azurerm_redis_cache.main.ssl_port
}

output "redis_url_secret_name" {
  description = "Key Vault secret name containing the Redis connection URL (rediss://)"
  value       = azurerm_key_vault_secret.redis_url.name
}

output "redis_key_secret_name" {
  description = "Key Vault secret name containing the primary Redis access key"
  value       = azurerm_key_vault_secret.redis_key.name
}
