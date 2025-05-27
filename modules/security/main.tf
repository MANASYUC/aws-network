resource "aws_security_group" "security_g" {
  name        = "security-g"
  description = "allows incoming traffic to access SSH and HTTPS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security-group-ssh-https"
  }
}

resource "aws_network_acl" "nw_acl" {
  vpc_id = var.vpc_id

  ingress {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.private_subnet_cidrs[0]
  }

  ingress {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = var.private_subnet_cidrs[1]
  }

  ingress {
    from_port  = 443
    to_port    = 443
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "network-acl"
  }
}

resource "aws_network_acl_association" "public" {
  count           = length(var.public_subnet_ids)
  subnet_id       = var.public_subnet_ids[count.index]
  network_acl_id  = aws_network_acl.nw_acl.id
}

resource "aws_network_acl_association" "private" {
  count           = length(var.private_subnet_ids)
  subnet_id       = var.private_subnet_ids[count.index]
  network_acl_id  = aws_network_acl.nw_acl.id
}
