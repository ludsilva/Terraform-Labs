variable "region" {
  description = "AWS region"
  default = "us-east-1"
}

## CIDR
variable "vpc_cidr" {
  description = "VPC main CIDR"
  default = "10.0.0.0/16"
}

## Public - ajustando para próximo laboratório
variable "public_subnets_cidr"  {
  description = "public subnets CIDR values"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  description = "private subnets CIDR"
  type = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  description = "EC2 instances type."
  type        = string
  default     = "t3.micro"
}