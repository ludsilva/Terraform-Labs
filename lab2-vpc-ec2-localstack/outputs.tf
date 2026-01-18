output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "dev_instance_id" {
  value = aws_instance.dev.id
}

output "prod_instance_id" {
  value = aws_instance.prod.id
}