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

variable "database_subnet_id" {
  description = "Subnet ID for PostgreSQL VNet injection (delegated to Microsoft.DBforPostgreSQL/flexibleServers)"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault resource ID for storing database credentials"
  type        = string
}

variable "database_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = "deploycloud"
}

variable "pg_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"

  validation {
    condition     = contains(["14", "15", "16"], var.pg_version)
    error_message = "Must be 14, 15, or 16."
  }
}

variable "sku_name" {
  description = "PostgreSQL Flexible Server SKU. B_Standard_B1ms (~$15/mo) staging, GP_Standard_D2s_v3 (~$120/mo) production."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Storage size in MB (minimum 32768)"
  type        = number
  default     = 32768

  validation {
    condition     = var.storage_mb >= 32768
    error_message = "Minimum storage is 32768 MB (32 GB)."
  }
}

variable "backup_retention_days" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Must be between 7 and 35 days."
  }
}

variable "geo_redundant_backup" {
  description = "Enable geo-redundant backups (production only; increases cost)"
  type        = bool
  default     = false
}

variable "high_availability_enabled" {
  description = "Enable zone-redundant HA standby (production only; approximately doubles cost)"
  type        = bool
  default     = false
}
