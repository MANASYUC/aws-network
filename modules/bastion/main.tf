data "aws_subnet" "public_subnet" {
  id = var.public_subnet_id
}

resource "aws_instance" "bastion" {
  count                       = var.enable_bastion ? 1 : 0
  ami                         = var.bastion_ami
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [var.bastion_sg_id]

  tags = {
    Name = "Bastion-Host"
  }
}
