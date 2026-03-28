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

variable "vpc_id" {
  description = "VPC ID where ECS resources will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least two public subnets are required for ALB high availability."
  }
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnets are required for ECS task high availability."
  }
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "ecs_task_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener"
  type        = string
}

variable "container_name" {
  description = "Name of the primary container in the task definition"
  type        = string
  default     = "app"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 3000

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "Container port must be between 1 and 65535."
  }
}

variable "health_check_path" {
  description = "ALB health check path"
  type        = string
  default     = "/health"
}

variable "task_cpu" {
  description = "Fargate task CPU units (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.task_cpu)
    error_message = "CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "task_memory" {
  description = "Fargate task memory in MiB"
  type        = number
  default     = 1024

  validation {
    condition     = var.task_memory >= 512 && var.task_memory <= 30720
    error_message = "Memory must be between 512 and 30720 MiB."
  }
}

variable "desired_count" {
  description = "Desired number of ECS task replicas"
  type        = number
  default     = 2

  validation {
    condition     = var.desired_count >= 1
    error_message = "Desired count must be at least 1."
  }
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks for auto-scaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks for auto-scaling"
  type        = number
  default     = 10
}

variable "container_image" {
  description = "Docker image URI for the application container"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Retention must be a valid CloudWatch Logs retention value."
  }
}

variable "environment_variables" {
  description = "Plain-text environment variables to inject into the container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets to inject as environment variables (key = env var name, value = Secrets Manager or SSM ARN)"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "fargate_spot_weight" {
  description = "Weight for Fargate Spot capacity (higher = more Spot usage)"
  type        = number
  default     = 4
}
