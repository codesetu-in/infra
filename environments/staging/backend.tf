terraform {
  backend "s3" {
    bucket = "deploycloud-tfstate-staging"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
