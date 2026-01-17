variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t3.micro"
}

variable "instance_name" {
  description = "EC2 instance name"
  type = string
  default = "ec2-localstack"
}