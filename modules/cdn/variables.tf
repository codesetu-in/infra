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
  description = "Name of the resource group"
  type        = string
}

variable "api_fqdn" {
  description = "FQDN of the platform API Container App"
  type        = string
}

variable "domain_name" {
  description = "Primary domain for the Front Door endpoint"
  type        = string
}

variable "health_check_path" {
  description = "HTTP path for origin health probes"
  type        = string
  default     = "/health"
}

variable "waf_rate_limit" {
  description = "Maximum requests per minute per IP before WAF blocks"
  type        = number
  default     = 2000
}
