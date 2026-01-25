data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu-22.04-jammy-jellyfish"]
  }

  owners = ["self"]
}


## Private instances
resource "aws_instance" "lab-ec2" {
  count = length(aws_subnet.private_subnets) # contador
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  
  subnet_id = aws_subnet.private_subnets[count.index].id
  vpc_security_group_ids = [aws_security_group.sg_private_ec2.id]

  associate_public_ip_address = false

  tags = {
    Name = "EC2-Lab${count.index +1}"
    Env = "Lab"
  }
}

##Tg attach
resource "aws_lb_target_group_attachment" "tg_attach" {
  count = length(aws_instance.lab-ec2)
  target_group_arn = aws_lb_target_group.lab_tg.arn
  target_id = aws_instance.lab-ec2[count.index].id
  port = 80

}
