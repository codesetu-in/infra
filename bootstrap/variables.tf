variable "aws_region" {
  description = "AWS region for bootstrap resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID used to ensure unique S3 bucket naming"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS account ID must be exactly 12 digits."
  }
}
