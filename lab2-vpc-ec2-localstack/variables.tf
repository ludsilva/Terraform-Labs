variable "region" {
  description = "AWS region"
  default = "us-east-1"
}

variable "az" {
  description = "AWS AZ"
  default = "us-east-1a"
}

## CIDR
variable "vpc_cidr" {
  description = "VPC main CIDR"
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr"  {
  description = "public subnets CIDR"
  type = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "private subnets CIDR"
  default = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instances type."
  type        = string
  default     = "t3.micro"
}