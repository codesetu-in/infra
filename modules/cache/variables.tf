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
  description = "Subnet IDs for the ElastiCache subnet group"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two subnets are required."
  }
}

variable "security_group_ids" {
  description = "Security group IDs for the Redis replication group"
  type        = list(string)
}

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t4g.small"
}

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.1"
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ with automatic failover (requires num_cache_clusters >= 2)"
  type        = bool
  default     = false
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (primary + replicas). Must be >= 2 when multi_az_enabled."
  type        = number
  default     = 1

  validation {
    condition     = var.num_cache_clusters >= 1 && var.num_cache_clusters <= 6
    error_message = "num_cache_clusters must be between 1 and 6."
  }
}

variable "snapshot_retention_limit" {
  description = "Days to retain automatic Redis snapshots"
  type        = number
  default     = 1
}

variable "maintenance_window" {
  description = "Weekly maintenance window"
  type        = string
  default     = "sun:05:00-sun:06:00"
}
