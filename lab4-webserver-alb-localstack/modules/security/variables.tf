variable "vpc_id" {
  description = "VPC where security groups will be created"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
