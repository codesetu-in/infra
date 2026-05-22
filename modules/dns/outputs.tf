output "zone_id" {
  description = "Azure DNS zone resource ID"
  value       = local.zone_id
}

output "zone_name" {
  description = "Azure DNS zone name"
  value       = local.zone_name
}

output "name_servers" {
  description = "Azure DNS zone name servers (delegate these at your registrar)"
  value       = var.create_zone ? azurerm_dns_zone.main[0].name_servers : []
}
