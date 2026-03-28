terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "deploycloud"
      ManagedBy = "terraform"
    }
  }
}

locals {
  name_prefix = "deploycloud"
}

# ── KMS ──────────────────────────────────────────────────────────────────────

resource "aws_kms_key" "terraform_state" {
  description             = "Encrypts Terraform remote state in S3 and DynamoDB"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/${local.name_prefix}-terraform-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}

# ── S3 state bucket ──────────────────────────────────────────────────────────

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.name_prefix}-tfstate-${var.aws_account_id}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# ── DynamoDB lock table ───────────────────────────────────────────────────────

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${local.name_prefix}-tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_state.arn
  }

  point_in_time_recovery {
    enabled = true
  }
}
