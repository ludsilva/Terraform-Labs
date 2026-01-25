resource "aws_security_group" "alb_sg" {
  name = "alb-sg"
  description = "SG for app load balancer"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP connections"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
    Env = "lab"
  }
}

resource "aws_security_group" "sg_private_ec2" {
  name = "private-ec2-sg"
  description = "SG for private ec2 instances"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Alow traffic from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-private-ec2"
    Env = "lab"
  }
}