## main VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
    Env = "lab"
  }
}

## Subnets
resource "aws_subnet" "public_subnet"{
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  availability_zone = var.az
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
    Tier = "public"
  }
}


resource "aws_subnet" "private_subnet"{
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr
  availability_zone = var.az

  tags = {
    Name = "private-subnet"
    Tier = "private"
  }
}

## IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW"
  }
}

### Public route table + association
resource "aws_route_table" "public_route_table"{
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

## EIP and Nat Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "Nat-EIP"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "NAT-Gateway"
  }
}

## Private route table + association
resource "aws_route_table" "private_route_table"{
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private-route-table"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}
