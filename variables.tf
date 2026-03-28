variable "aws_region" {
  description = "Primary AWS region for all resources"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "Must be a valid AWS region identifier (e.g. us-east-1)."
  }
}

variable "environment" {
  description = "Deployment environment (staging or production)"
  type        = string

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Must be 'staging' or 'production'."
  }
}
