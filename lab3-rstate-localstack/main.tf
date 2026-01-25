provider "aws" {
  region = var.region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style = true

  endpoints {
    ec2 = "http://localhost:4566"
    elbv2 = "http://localhost:4566"
    s3    = "http://localhost:4566"
  }
}

## Target group
resource "aws_lb_target_group" "lab_tg" {
  name = "lab-tg"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.main.id
}

## ALB
resource "aws_lb" "lab_alb" {
  name = "lab-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = aws_subnet.public_subnets[*].id

  tags = {
    Name = "lab-alb"
  }
}

## listener
resource "aws_lb_listener" "lab_alb_listener"{
  load_balancer_arn = aws_lb.lab_alb.arn
  port = 80
  protocol = "HTTP"

 default_action {
   type = "forward"
   target_group_arn = aws_lb_target_group.lab_tg.arn
 }
}