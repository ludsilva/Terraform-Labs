provider "aws" {
  region = var.region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
  }
}

## Data source
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-22.04-jammy-jellyfish"]
  }
  owners = ["self"]
}


## Public isntance
resource "aws_instance" "dev" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.sg_public_ec2.id
  ]

  subnet_id = aws_subnet.public_subnet.id

  tags = {
    Name = "EC2-Dev-Public"
    Env = "dev"
  }
}


## Private instance
resource "aws_instance" "prod" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.sg_private_ec2.id
  ]

  subnet_id = aws_subnet.private_subnet.id

  associate_public_ip_address = false

  tags = {
    Name = "EC2-Prod-Private"
    Env = "prod"
  }
}


