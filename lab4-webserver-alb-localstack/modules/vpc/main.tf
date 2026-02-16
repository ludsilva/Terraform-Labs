## Data source para pegar as AZs e evitar hardcoding
data "aws_availability_zones" "available" {
  state = "available"
}

## VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = var.vpc_name
  })
}

## Public subnets
resource "aws_subnet" "public_subnets"{
  count = length(var.public_subnets_cidr)
  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnets_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index] ## 
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "public-subnet-${count.index + 1}"
    Tier = "public"
  })
}

## Private subnets
resource "aws_subnet" "private_subnets"{
  count = length(var.private_subnets_cidr)
  vpc_id = aws_vpc.this.id
  cidr_block = var.private_subnets_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(var.tags, {
    Name = "private-subnet-${count.index + 1}"
    Tier = "private"
  })
}

## IGW
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "IGW"
  })
}

### Public route table + associations
resource "aws_route_table" "public_route_table"{
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "public-route-table"
  })
}

resource "aws_route_table_association" "public_subnet_association" {
  count = length(aws_subnet.public_subnets) ## count com base nas subnets publicas
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

## EIP and Nat Gateways
resource "aws_eip" "nat_eip" {
  count = length(aws_subnet.public_subnets)
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "nat-eip-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "this" {
  count = length(aws_subnet.public_subnets) 
  allocation_id = aws_eip.nat_eip[count.index].id 
  subnet_id = aws_subnet.public_subnets[count.index].id ##um nat gateway pra cada AZ

  tags = merge(var.tags, {
    Name = "nat-gateway-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.this] ## recomendação na doc
}

## Private route table + associations
resource "aws_route_table" "private_route_table"{
  count = length(aws_subnet.private_subnets)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = merge(var.tags, {
    Name = "private-route-table-${count.index + 1}"
  })
}

resource "aws_route_table_association" "private_subnet_association" {
  count = length(aws_subnet.private_subnets)
  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}