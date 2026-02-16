terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket = "lab4-tf-state"
    key                         = "lab-04/terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    force_path_style            = true

    endpoints = {
      s3 = "http://localhost:4566"
    }
  }
}

## config localstack (temporário)
provider "aws" {
  region                      = var.region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2   = "http://localhost:4566"
    s3    = "http://localhost:4566"
    elbv2 = "http://localhost:4566"
    rds   = "http://localhost:4566"
    iam   = "http://localhost:4566"
    sts   = "http://localhost:4566"
  }
}