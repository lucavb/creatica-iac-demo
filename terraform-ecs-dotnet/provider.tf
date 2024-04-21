provider "aws" {
  region              = "eu-central-1"
  allowed_account_ids = [var.aws_account_id]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
    }
  }

  required_version = ">= 1.2.0"


  backend "s3" {
    bucket = "beckerl-terraform-state"
    key    = "terraform/my-cool-state"
    region = "eu-central-1"
  }

}