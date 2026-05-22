terraform {
  backend "azurerm" {
    resource_group_name  = "deploycloud-tfstate-rg"
    storage_account_name = "REPLACE_WITH_BOOTSTRAP_OUTPUT"
    container_name       = "tfstate"
    key                  = "production/terraform.tfstate"
    use_oidc             = true
  }
}
