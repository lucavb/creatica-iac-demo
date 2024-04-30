provider "aws" {
  region              = "eu-west-1"
  allowed_account_ids = [941982015192]
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
    bucket = "creatica-workshop-tf-state"
    key    = "ecs-demo/creatica-workshop-state"
    region = "eu-west-1"
  }

}