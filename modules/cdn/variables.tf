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

variable "alb_dns_name" {
  description = "DNS name of the ALB used as the CloudFront origin"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name (e.g. deploycloud.app or staging.deploycloud.app)"
  type        = string
}

variable "zone_id" {
  description = "Route53 hosted zone ID used for ACM certificate DNS validation"
  type        = string
}

variable "price_class" {
  description = "CloudFront price class — controls which edge locations are used"
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.price_class)
    error_message = "Must be PriceClass_All, PriceClass_200, or PriceClass_100."
  }
}

variable "waf_rate_limit" {
  description = "Maximum requests per 5-minute window per IP before WAF blocks"
  type        = number
  default     = 2000

  validation {
    condition     = var.waf_rate_limit >= 100
    error_message = "WAF rate limit must be at least 100 requests."
  }
}

variable "geo_restriction_locations" {
  description = "ISO 3166-1 alpha-2 country codes to block (empty = no restriction)"
  type        = list(string)
  default     = []
}
