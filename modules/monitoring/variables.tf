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

variable "ecs_cluster_name" {
  description = "ECS cluster name for CloudWatch metrics"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name for CloudWatch metrics"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics (e.g. app/my-alb/1234567890abcdef)"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix for CloudWatch metrics"
  type        = string
}

variable "sns_email_endpoint" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string

  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.sns_email_endpoint))
    error_message = "Must be a valid email address."
  }
}

variable "cpu_alarm_threshold" {
  description = "ECS CPU utilization percentage that triggers an alarm"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_alarm_threshold > 0 && var.cpu_alarm_threshold <= 100
    error_message = "CPU threshold must be between 1 and 100."
  }
}

variable "error_rate_threshold" {
  description = "ALB 5xx error rate percentage that triggers an alarm"
  type        = number
  default     = 1

  validation {
    condition     = var.error_rate_threshold > 0 && var.error_rate_threshold <= 100
    error_message = "Error rate threshold must be between 1 and 100."
  }
}

variable "alarm_evaluation_periods" {
  description = "Number of consecutive periods before an alarm fires"
  type        = number
  default     = 2
}
