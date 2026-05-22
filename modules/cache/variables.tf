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
  description = "Key Vault resource ID for storing Redis credentials"
  type        = string
}

variable "sku_name" {
  description = "Redis SKU. Basic (~$16/mo) for staging, Standard (~$90/mo) for production with HA."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "Must be Basic, Standard, or Premium."
  }
}

variable "sku_family" {
  description = "Redis SKU family: C (Basic/Standard) or P (Premium)"
  type        = string
  default     = "C"
}

variable "capacity" {
  description = "Redis cache size (0=250MB, 1=1GB, 2=2.5GB, etc.)"
  type        = number
  default     = 0
}

variable "redis_version" {
  description = "Redis major version"
  type        = number
  default     = 7
}

variable "maxmemory_policy" {
  description = "Redis eviction policy"
  type        = string
  default     = "allkeys-lru"
}

variable "enable_private_endpoint" {
  description = "Route Redis traffic through a private endpoint (production; requires Standard or Premium SKU)"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the Redis private endpoint (required when enable_private_endpoint = true)"
  type        = string
  default     = null
}

variable "redis_private_dns_zone_id" {
  description = "Private DNS zone ID for Redis private endpoint DNS resolution"
  type        = string
  default     = null
}

variable "persistence_connection_string" {
  description = "Storage account connection string for AOF persistence (Standard/Premium only)"
  type        = string
  default     = null
  sensitive   = true
}
