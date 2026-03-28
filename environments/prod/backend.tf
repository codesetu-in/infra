terraform {
  backend "s3" {
    bucket = "deploycloud-tfstate-prod"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
