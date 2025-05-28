resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from specific IP"
  vpc_id      = data.aws_subnet.public_subnet.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_subnet" "public_subnet" {
  id = var.public_subnet_id
}

resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "Bastion-Host"
  }
}
