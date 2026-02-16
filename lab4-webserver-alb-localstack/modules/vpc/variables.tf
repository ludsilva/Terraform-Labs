variable "vpc_name" {
  description = "Name of VPC"
  type = string  
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type = string
}

variable "public_subnets_cidr"  {
  description = "public subnets CIDR values"
  type = list(string)
}

variable "private_subnets_cidr" {
  description = "private subnets cidr values"
  type = list(string)
}

variable "tags" {
  description = "Tags to apply to VPCs resources"
  type =  map(string)
  default = {}
}
