provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    region = "eu-west-1"
    bucket = "mstykow-state"
    key    = "terraform.tfstate"
    dynamodb_table = "mstykow-terraform-lock"
  }
}
