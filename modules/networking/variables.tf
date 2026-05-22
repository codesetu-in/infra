variable "name_prefix" {
  description = "Prefix applied to all resource names"
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 20 && can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "name_prefix must be lowercase alphanumeric with hyphens, max 20 chars."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Must be 'staging' or 'production'."
  }
}

variable "azure_region" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "vnet_cidr" {
  description = "Address space for the Virtual Network"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vnet_cidr))
    error_message = "Must be a valid CIDR block."
  }
}

variable "container_apps_subnet_cidr" {
  description = "CIDR for Container Apps Environment dedicated subnet (min /27, recommended /23)"
  type        = string
  default     = "10.0.0.0/23"
}

variable "database_subnet_cidr" {
  description = "CIDR for the PostgreSQL Flexible Server delegated subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "private_endpoint_subnet_cidr" {
  description = "CIDR for private endpoints subnet (Redis in production)"
  type        = string
  default     = "10.0.5.0/24"
}
