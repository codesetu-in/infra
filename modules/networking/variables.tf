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

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "Must be a valid CIDR block."
  }
}

variable "azs" {
  description = "List of exactly two Availability Zone names"
  type        = list(string)

  validation {
    condition     = length(var.azs) == 2
    error_message = "Exactly two Availability Zones are required."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly two public subnet CIDRs are required."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private (app) subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Exactly two private subnet CIDRs are required."
  }
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for isolated database subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]

  validation {
    condition     = length(var.database_subnet_cidrs) == 2
    error_message = "Exactly two database subnet CIDRs are required."
  }
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for all AZs (reduces cost for non-prod)"
  type        = bool
  default     = true
}
