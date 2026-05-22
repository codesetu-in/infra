variable "name_prefix" {
  description = "Prefix applied to all resource names"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Must be 'staging' or 'production'."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy into"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault resource ID for storing connection strings"
  type        = string
}

variable "acr_sku" {
  description = "Azure Container Registry SKU. Basic (~$5/mo), Standard (~$20/mo), Premium (~$50/mo)."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "Must be Basic, Standard, or Premium."
  }
}

variable "untagged_retention_days" {
  description = "Days to retain untagged images (Premium SKU only)"
  type        = number
  default     = 7
}

variable "geo_replication_regions" {
  description = "Additional regions for ACR geo-replication (Standard/Premium only)"
  type        = list(string)
  default     = []
}

variable "container_apps_identity_principal_id" {
  description = "Principal ID of the Container Apps managed identity for AcrPull access"
  type        = string
  default     = null
}

variable "build_engine_identity_principal_id" {
  description = "Principal ID of the build-engine managed identity for AcrPush access"
  type        = string
  default     = null
}
