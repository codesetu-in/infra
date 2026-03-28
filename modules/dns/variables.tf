variable "domain_name" {
  description = "Root domain name for the hosted zone (e.g. deploycloud.app)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]+\\.[a-z]{2,}$", var.domain_name))
    error_message = "Must be a valid domain name."
  }
}

variable "create_zone" {
  description = "Whether to create a new Route53 hosted zone. Set false to use an existing zone."
  type        = bool
  default     = true
}

variable "alb_dns_name" {
  description = "DNS name of the ALB for the wildcard alias record"
  type        = string
}

variable "alb_zone_id" {
  description = "Route53 hosted zone ID of the ALB"
  type        = string
}

variable "environment" {
  description = "Deployment environment (used for tagging)"
  type        = string

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Must be 'staging' or 'production'."
  }
}

variable "name_prefix" {
  description = "Prefix applied to resource names"
  type        = string
}
