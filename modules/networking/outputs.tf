output "resource_group_name" {
  description = "Name of the main resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the main resource group"
  value       = azurerm_resource_group.main.location
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = azurerm_virtual_network.main.name
}

output "container_apps_subnet_id" {
  description = "Subnet ID for Container Apps Environment"
  value       = azurerm_subnet.container_apps.id
}

output "database_subnet_id" {
  description = "Subnet ID for PostgreSQL Flexible Server"
  value       = azurerm_subnet.database.id
}

output "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoints"
  value       = azurerm_subnet.private_endpoints.id
}

output "postgres_private_dns_zone_id" {
  description = "Private DNS zone ID for PostgreSQL"
  value       = azurerm_private_dns_zone.postgres.id
}

output "redis_private_dns_zone_id" {
  description = "Private DNS zone ID for Redis"
  value       = azurerm_private_dns_zone.redis.id
}
