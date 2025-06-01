resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  instance = aws_instance.nat_instance.id
}

# NAT Instance Security Group
resource "aws_security_group" "nat_sg" {
  name        = "nat-instance-sg"
  description = "Security group for NAT Instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nat-instance-sg"
  }
}

# NAT Instance
resource "aws_instance" "nat_instance" {
  ami           = var.nat_instance_ami  # You'll need to specify an Amazon NAT Instance AMI
  instance_type = "t2.micro"           # Free tier eligible
  subnet_id     = var.public_subnet_ids[0]

  source_dest_check = false  # Required for NAT functionality
  
  vpc_security_group_ids = [aws_security_group.nat_sg.id]

  tags = {
    Name = "nat-instance"
  }
}
