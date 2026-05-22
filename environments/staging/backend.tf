terraform {
  # After running bootstrap, fill in the values from its outputs:
  #   storage_account_name = output from bootstrap
  #   resource_group_name  = output from bootstrap
  backend "azurerm" {
    resource_group_name  = "deploycloud-tfstate-rg"
    storage_account_name = "REPLACE_WITH_BOOTSTRAP_OUTPUT"
    container_name       = "tfstate"
    key                  = "staging/terraform.tfstate"
    use_oidc             = true   # use workload identity / service principal OIDC in CI
  }
}
