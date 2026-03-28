terraform {
  backend "s3" {
    # Replace ACCOUNT_ID with your 12-digit AWS account ID after running bootstrap
    bucket         = "deploycloud-tfstate-ACCOUNT_ID"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "deploycloud-tfstate-locks"
    encrypt        = true
  }
}
