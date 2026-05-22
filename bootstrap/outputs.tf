output "storage_account_name" {
  description = "Azure Storage Account name for Terraform remote state"
  value       = azurerm_storage_account.tfstate.name
}

output "storage_container_name" {
  description = "Blob container name for Terraform remote state"
  value       = azurerm_storage_container.tfstate.name
}

output "resource_group_name" {
  description = "Resource group containing the Terraform state storage account"
  value       = azurerm_resource_group.tfstate.name
}

output "key_vault_uri" {
  description = "Key Vault URI for bootstrap secrets"
  value       = azurerm_key_vault.bootstrap.vault_uri
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.bootstrap.name
}
