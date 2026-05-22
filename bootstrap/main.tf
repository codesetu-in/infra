terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  name_prefix = "deploycloud"
}

data "azurerm_client_config" "current" {}

# ── Resource Group ────────────────────────────────────────────────────────────

resource "azurerm_resource_group" "tfstate" {
  name     = "${local.name_prefix}-tfstate-rg"
  location = var.azure_region

  tags = {
    Project   = "deploycloud"
    ManagedBy = "terraform"
  }
}

# ── Random suffix for globally unique names ───────────────────────────────────

resource "random_id" "suffix" {
  byte_length = 4
}

# ── Storage Account for Terraform State ──────────────────────────────────────
# Azure Blob Storage backend natively handles state locking via blob leases
# (no separate DynamoDB equivalent is needed).

resource "azurerm_storage_account" "tfstate" {
  name                = "${local.name_prefix}tfstate${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version           = "TLS1_2"
  https_traffic_only_enabled = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 90
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  tags = azurerm_resource_group.tfstate.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

# ── Key Vault for bootstrap secrets ──────────────────────────────────────────

resource "azurerm_key_vault" "bootstrap" {
  name                = "${local.name_prefix}-kv-${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  # Allow the operator running bootstrap to manage secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover"
    ]
    key_permissions = [
      "Get", "List", "Create", "Delete", "Purge", "Recover",
      "GetRotationPolicy", "SetRotationPolicy"
    ]
  }

  tags = azurerm_resource_group.tfstate.tags
}
