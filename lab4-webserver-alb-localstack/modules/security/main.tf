## Sg ALB
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
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

  tags = merge(var.tags, 
  { Name = "alb-sg" 
  })
}

##Sg Ec2 dev

resource "aws_security_group" "ec2_dev" {
  name        = "ec2-dev-sg"
  description = "EC2 Dev security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] ## permitir somente trafego do alb
  }

  egress {
    from_port = 0
    to_port = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { 
    Name = "ec2-dev-sg" 
  })
}

## Ec2 prod

resource "aws_security_group" "ec2_prod" {
  name        = "ec2-prod-sg"
  description = "EC2 Prod security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "ec2-prod-sg" })
}

## Rds dev

resource "aws_security_group" "rds_dev" {
  name        = "rds-dev-sg"
  description = "RDS Dev security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres from EC2 Dev"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_dev.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { 
    Name = "rds-dev-sg" 
  })
}

## RDS prod
resource "aws_security_group" "rds_prod" {
  name        = "rds-prod-sg"
  description = "RDS Prod security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres from EC2 Prod"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_prod.id] ## permitir somente trafego da ec2 prod
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { 
    Name = "rds-prod-sg" 
  })
}
