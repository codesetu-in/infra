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

variable "subnet_ids" {
  description = "Subnet IDs for the Aurora cluster (should be database subnets)"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two subnets are required for Aurora multi-AZ."
  }
}

variable "security_group_ids" {
  description = "Security group IDs attached to the Aurora cluster"
  type        = list(string)
}

variable "database_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = "deploycloud"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database_name))
    error_message = "Database name must start with a letter and contain only alphanumeric characters and underscores."
  }
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "16.4"
}

variable "min_capacity" {
  description = "Minimum Aurora Serverless v2 capacity in ACUs"
  type        = number
  default     = 0.5

  validation {
    condition     = var.min_capacity >= 0.5 && var.min_capacity <= 128
    error_message = "Minimum capacity must be between 0.5 and 128 ACUs."
  }
}

variable "max_capacity" {
  description = "Maximum Aurora Serverless v2 capacity in ACUs"
  type        = number
  default     = 8

  validation {
    condition     = var.max_capacity >= 1 && var.max_capacity <= 128
    error_message = "Maximum capacity must be between 1 and 128 ACUs."
  }
}

variable "backup_retention_period" {
  description = "Automated backup retention in days"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "Backup retention must be between 1 and 35 days."
  }
}

variable "deletion_protection" {
  description = "Enable deletion protection on the cluster"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on cluster deletion (set true for ephemeral environments)"
  type        = bool
  default     = false
}

variable "preferred_maintenance_window" {
  description = "Weekly maintenance window (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "preferred_backup_window" {
  description = "Daily backup window (UTC) — must not overlap maintenance window"
  type        = string
  default     = "02:00-03:00"
}
