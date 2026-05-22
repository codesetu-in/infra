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

variable "alerts_email" {
  description = "Email address for alert notifications"
  type        = string

  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.alerts_email))
    error_message = "Must be a valid email address."
  }
}

variable "container_app_api_id" {
  description = "Resource ID of the platform API Container App"
  type        = string
}

variable "postgres_server_id" {
  description = "Resource ID of the PostgreSQL Flexible Server (optional)"
  type        = string
  default     = null
}

variable "cpu_alarm_threshold" {
  description = "CPU percentage threshold for the high-CPU alert"
  type        = number
  default     = 80
}

variable "error_rate_threshold" {
  description = "5xx request count threshold per 5-minute window"
  type        = number
  default     = 10
}
