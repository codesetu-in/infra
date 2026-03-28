output "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "S3 bucket ARN for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table name used for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "kms_key_arn" {
  description = "KMS key ARN used to encrypt state bucket and DynamoDB table"
  value       = aws_kms_key.terraform_state.arn
}

output "kms_key_alias" {
  description = "KMS key alias"
  value       = aws_kms_alias.terraform_state.name
}
