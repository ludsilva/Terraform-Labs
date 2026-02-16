output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "ec2_dev_sg_id" {
  value = aws_security_group.ec2_dev.id
}

output "ec2_prod_sg_id" {
  value = aws_security_group.ec2_prod.id
}

output "rds_dev_sg_id" {
  value = aws_security_group.rds_dev.id
}

output "rds_prod_sg_id" {
  value = aws_security_group.rds_prod.id
}
