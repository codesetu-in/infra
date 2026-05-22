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

variable "container_apps_subnet_id" {
  description = "Subnet ID for Container Apps Environment VNet injection"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault resource ID for managed identity secret access"
  type        = string
}

variable "acr_login_server" {
  description = "ACR login server URL (e.g. deploycloud.azurecr.io)"
  type        = string
}

variable "log_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 30
}

# ── API Container App settings ────────────────────────────────────────────────

variable "api_image_name" {
  description = "ACR image name for the platform API"
  type        = string
  default     = "platform-api"
}

variable "api_image_tag" {
  description = "Image tag for the platform API"
  type        = string
  default     = "latest"
}

variable "api_port" {
  description = "Port the platform API listens on"
  type        = number
  default     = 3001
}

variable "health_check_path" {
  description = "HTTP path for liveness/readiness probes"
  type        = string
  default     = "/health"
}

variable "api_cpu" {
  description = "vCPU allocation for the API container (e.g. 0.5)"
  type        = number
  default     = 0.5
}

variable "api_memory" {
  description = "Memory allocation for the API container (e.g. '1Gi')"
  type        = string
  default     = "1Gi"
}

variable "api_min_replicas" {
  description = "Minimum number of API replicas (0 = scale to zero)"
  type        = number
  default     = 0
}

variable "api_max_replicas" {
  description = "Maximum number of API replicas"
  type        = number
  default     = 5
}

variable "api_environment_variables" {
  description = "Plain-text environment variables for the API container"
  type        = map(string)
  default     = {}
}

variable "api_secret_refs" {
  description = "Map of env var name → Container App secret name (secrets fetched from Key Vault)"
  type        = map(string)
  default     = {}
}

variable "api_key_vault_secrets" {
  description = "Map of Container App secret name → Key Vault secret URI (for Key Vault integration)"
  type        = map(string)
  default     = {}
}

# ── Dashboard Container App settings ─────────────────────────────────────────

variable "dashboard_image_name" {
  description = "ACR image name for the dashboard"
  type        = string
  default     = "platform-dashboard"
}

variable "dashboard_image_tag" {
  description = "Image tag for the dashboard"
  type        = string
  default     = "latest"
}

variable "dashboard_cpu" {
  description = "vCPU allocation for the dashboard container"
  type        = number
  default     = 0.5
}

variable "dashboard_memory" {
  description = "Memory allocation for the dashboard container"
  type        = string
  default     = "1Gi"
}

variable "dashboard_min_replicas" {
  description = "Minimum number of dashboard replicas (0 = scale to zero)"
  type        = number
  default     = 0
}

variable "dashboard_max_replicas" {
  description = "Maximum number of dashboard replicas"
  type        = number
  default     = 3
}

variable "dashboard_environment_variables" {
  description = "Plain-text environment variables for the dashboard container"
  type        = map(string)
  default     = {}
}
