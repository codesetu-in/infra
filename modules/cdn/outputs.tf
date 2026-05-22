output "frontdoor_profile_id" {
  description = "Azure Front Door profile resource ID"
  value       = azurerm_cdn_frontdoor_profile.main.id
}

output "frontdoor_endpoint_fqdn" {
  description = "Front Door endpoint hostname"
  value       = azurerm_cdn_frontdoor_endpoint.main.host_name
}

output "waf_policy_id" {
  description = "WAF firewall policy resource ID"
  value       = azurerm_cdn_frontdoor_firewall_policy.main.id
}
