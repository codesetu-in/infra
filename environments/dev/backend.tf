terraform {
  backend "s3" {
    bucket = "deploycloud-tfstate-dev"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
