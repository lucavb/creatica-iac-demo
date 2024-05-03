provider "aws" {
  region              = "eu-west-1"
  allowed_account_ids = [123456789] # replace with your account id
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
    bucket = "creatica-workshop-tf-state" # replace with your bucket name
    key    = "ecs-demo/creatica-workshop-state" # can be any key you want
    region = "eu-west-1"
  }

}