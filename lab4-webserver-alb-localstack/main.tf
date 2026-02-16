## chamando módulo vpc
module "vpc" {
  source = "./modules/vpc" ## Modulo local

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr

  tags = {
    Project = "Lab4"
  }
}

## cahamr modulo security groups
module "security" {
  source = "./modules/security"

  vpc_id = module.vpc.vpc_id

  tags = {
    Project = "Lab4"
  }
}


## cmahar módulo ec2 prod
module "ec2_prod" {
  source = "./modules/ec2"

  name                = "lab4-prod"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  instance_type       = "t3.micro"
  instance_count      = 1
  associate_public_ip = false

  security_group_ids = [module.security.ec2_prod_sg_id]

  tags = {
    Project = "Lab4"
    Env     = "Prod"
  }
}

module "ec2_dev" {
  source = "./modules/ec2"

  name                = "lab-4dev"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.public_subnet_ids
  instance_type       = "t3.micro"
  instance_count      = 1
  associate_public_ip = true

  security_group_ids = [module.security.ec2_dev_sg_id]

  tags = {
    Project = "Lab4"
    Env     = "Dev"
  }
}


## Chamar modulo rds - teste
module "rds_prod" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.1.0"

  identifier = "lab4-postgres-prod"
  engine                      = "postgres"
  engine_version              = "15"
  family                      = "postgres15"
  instance_class              = "db.t3.micro"
  allocated_storage           = 20
  db_name    = "appdb"
  username     = "admin"
  manage_master_user_password = true
  port                        = "5432"
  publicly_accessible         = false
  deletion_protection         = true
  skip_final_snapshot         = false
  subnet_ids                  = module.vpc.private_subnet_ids
  vpc_security_group_ids      = [module.security.rds_prod_sg_id]
  create_db_subnet_group      = true

  tags = {
    Project = "Lab4"
    Env     = "Prod"
  }
}

module "rds_dev" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.1.0"

  identifier = "lab4-postgres-dev"

  engine                      = "postgres"
  engine_version              = "15"
  family                      = "postgres15"
  instance_class              = "db.t3.micro"
  allocated_storage           = 20
  db_name                     = "appdb"
  username                    = "admin"
  manage_master_user_password = true
  port                        = "5432"
  publicly_accessible         = false
  subnet_ids                  = module.vpc.private_subnet_ids
  vpc_security_group_ids      = [module.security.rds_dev_sg_id]

  create_db_subnet_group = true

  tags = {
    Project = "Lab4"
    Env     = "Dev"
  }
}

## S3
### dev log test
resource "aws_s3_bucket" "dev_access_log" {
  bucket = "lab4-dev-access-log"

  tags = {
    Env     = "Dev"
    Project = "Lab4"
  }
}

resource "aws_s3_bucket" "dev_error_log" {
  bucket = "lab4-dev-error-log"

  tags = {
    Env     = "Dev"
    Project = "Lab4"
  }
}

resource "aws_s3_bucket" "prod_access_log" {
  bucket = "lab4-prod-access-log"

  tags = {
    Env     = "Prod"
    Project = "Lab4"
  }
}

resource "aws_s3_bucket" "prod_error_log" {
  bucket = "lab4-prod-error-log"

  tags = {
    Project = "Lab4"
    Env     = "Prod"
  }
}

## ALB dev

module "alb_dev" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.0.0"

  name               = "albdev"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnet_ids
  security_groups    = [module.security.alb_sg_id]

  access_logs = {
    bucket  = aws_s3_bucket.dev_access_log.bucket
    enabled = true
  }

  target_groups = [
    {
      name_prefix      = "devtg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"

      targets = [
        for id in module.ec2_dev.instance_ids : {
          target_id = id
          port      = 80
        }
      ]
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Env     = "Dev"
    Project = "Lab4"
  }
}

## modeule prod
module "alb_prod" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.0.0"

  name               = "albprod"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id

  # Mesmo que seja prod, o ALB precisa estar em subnets públicas
  subnets         = module.vpc.public_subnet_ids
  security_groups = [module.security.alb_sg_id]

  target_groups = [
    {
      name_prefix      = "prodtg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"

      targets = [
        for id in module.ec2_prod.instance_ids : {
          target_id = id
          port      = 80
        }
      ]
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Project = "Lab4"
    Env     = "Prod"
  }
}
