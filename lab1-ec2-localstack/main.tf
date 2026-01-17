provider "aws" {
  region = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}


resource "aws_instance" "example" {
  ami = "ami-12345678"
  instance_type = var.instance_type ## variable

  tags = {
    Name = var.instance_name
    Env = "local"
  }
}