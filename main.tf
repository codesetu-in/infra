terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Primary regional provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "deploycloud"
      ManagedBy   = "terraform"
    }
  }
}

# Global provider for CloudFront, WAF, and ACM (CloudFront requires us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "deploycloud"
      ManagedBy   = "terraform"
    }
  }
}
