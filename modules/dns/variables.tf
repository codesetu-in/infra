variable "name_prefix" {
  description = "Prefix applied to resource names"
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
  description = "Resource group name"
  type        = string
}

variable "domain_name" {
  description = "Root domain name for the DNS zone (e.g. deploycloud.app)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]+\\.[a-z]{2,}$", var.domain_name))
    error_message = "Must be a valid domain name."
  }
}

variable "create_zone" {
  description = "Whether to create a new DNS zone. Set false to use an existing zone."
  type        = bool
  default     = true
}

variable "container_apps_default_domain" {
  description = "Container Apps Environment default domain for CNAME records (e.g. {env-name}.{region}.azurecontainerapps.io)"
  type        = string
}

variable "custom_domain_verification_id" {
  description = "Container Apps Environment custom domain verification ID (for TXT record)"
  type        = string
  default     = null
}
