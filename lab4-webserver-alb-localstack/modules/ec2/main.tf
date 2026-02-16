## Data source for AMI
data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-22.04-jammy-jellyfish"]
  }
  owners = ["self"] ## usar para aws: ["099720109477"]
}

## EC2
resource "aws_instance" "this" {
  count = var.instance_count
  ami = data.aws_ami.this.id
  instance_type = var.instance_type
  subnet_id = var.subnet_ids[count.index % length(var.subnet_ids)] ### distribuição das instâncias entre as subnets, passei instance count =1 no main do root
  vpc_security_group_ids = var.security_group_ids 
  associate_public_ip_address = var.associate_public_ip

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    environment   = var.tags["Env"]
    instance_name = var.name
  })

  tags = merge(var.tags, {
    Name = "${var.name}-${count.index + 1}"
  })
}