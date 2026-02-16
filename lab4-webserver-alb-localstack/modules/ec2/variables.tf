variable "name" {
  type = string
}

variable "vpc_id" {
  description = "VPC ID where EC2 will be deployed"
  type = string
}

variable "subnet_ids" {
  description = "Subnets for EC2 instances"
  type = list(string)

}

variable "instance_type" {
  description = "EC2 instances type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type = number
}

variable "associate_public_ip" {
  type = bool
}

variable "security_group_ids" {
  description = "Security groups to attach to EC2"
  type        = list(string)
}

variable "tags" {
  description = "Common tags"
  type = map(string)
  default = {}
}