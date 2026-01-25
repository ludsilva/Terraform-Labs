## AZs
data "aws_availability_zones" "available" {
  state = "available"
}


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

## Public subnets
resource "aws_subnet" "public_subnets"{
  count = length(var.public_subnets_cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.public_subnets_cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index] 
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${count.index + 1}"
    Tier = "public"
  }
}

## Private subnets
resource "aws_subnet" "private_subnets"{
  count = length(var.private_subnets_cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.private_subnets_cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index] 

  tags = {
    Name = "Private Subnet ${count.index + 1}"
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
  count = length(var.public_subnets_cidr)
  subnet_id = aws_subnet.public_subnets[count.index].id
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
  subnet_id = aws_subnet.public_subnets[0].id # Por enquanto, somente 1

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
  count = length(var.private_subnets_cidr)
  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}