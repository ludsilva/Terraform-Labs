resource "aws_security_group" "sg_public_ec2" {
  name = "public-ec2-sg"
  description = "SG for public ec2 (dev)"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH rule"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-public-ec2"
    Env = "lab"
  }
}

resource "aws_security_group" "sg_private_ec2" {
  name = "private-ec2-sg"
  description = "SG for private ec2 (prod)"
  vpc_id = aws_vpc.main.id

    ingress {
    description = "Alow traffic from public sg"
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    security_groups = [aws_security_group.sg_public_ec2.id]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-private-ec2"
    Env = "lab"
  }
}