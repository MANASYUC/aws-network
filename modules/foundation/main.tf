# ====================================
# FOUNDATION MODULE - CORE NETWORKING
# ====================================
# This module creates the fundamental network infrastructure:
# - VPC with DNS support
# - Public & Private subnets across AZs  
# - Internet Gateway for public access
# - NAT Instance for private subnet internet access (free tier friendly)
# - Route tables and associations
# ====================================

# VPC - Virtual Private Cloud
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${var.environment}-vpc"
    Type = "Foundation"
  })
}

# Internet Gateway - Enables internet access for public subnets
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-igw"
    Type = "Foundation"
  })
}

# Public Subnets - For resources that need direct internet access
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
    Type = "Public"
    AZ   = var.availability_zones[count.index]
  })
}

# Private Subnets - For resources that should not have direct internet access
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
    Type = "Private"
    AZ   = var.availability_zones[count.index]
  })
}

# Security Group for NAT Instance
resource "aws_security_group" "nat_instance" {
  count       = var.enable_nat_instance ? 1 : 0
  name        = "${var.environment}-nat-instance-sg"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP traffic from private subnets
  ingress {
    description = "HTTP from private subnets"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  # Allow HTTPS traffic from private subnets
  ingress {
    description = "HTTPS from private subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  # Allow SSH from admin networks (for troubleshooting)
  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-nat-instance-sg"
    Type = "Foundation"
  })
}

# Elastic IP for NAT Instance
resource "aws_eip" "nat" {
  count  = var.enable_nat_instance ? 1 : 0
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = merge(var.common_tags, {
    Name = "${var.environment}-nat-eip"
    Type = "Foundation"
  })
}

# NAT Instance - Free tier friendly alternative to NAT Gateway
resource "aws_instance" "nat" {
  count                       = var.enable_nat_instance ? 1 : 0
  ami                        = var.nat_instance_ami_id
  instance_type              = var.nat_instance_type
  key_name                   = var.key_name
  vpc_security_group_ids     = [aws_security_group.nat_instance[0].id]
  subnet_id                  = aws_subnet.public[0].id
  associate_public_ip_address = true
  source_dest_check          = false  # Critical for NAT functionality

  user_data = <<-EOF
    #!/bin/bash
    # Update system
    yum update -y
    
    # Enable IP forwarding
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    sysctl -p
    
    # Configure iptables for NAT
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    iptables -A FORWARD -i eth0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT
    
    # Save iptables rules permanently
    service iptables save
    chkconfig iptables on
    
    # Start iptables service
    service iptables start
  EOF

  tags = merge(var.common_tags, {
    Name = "${var.environment}-nat-instance"
    Type = "Foundation"
    Role = "NAT"
  })

  depends_on = [aws_internet_gateway.main]
}

# Associate Elastic IP with NAT Instance
resource "aws_eip_association" "nat" {
  count       = var.enable_nat_instance ? 1 : 0
  instance_id = aws_instance.nat[0].id
  allocation_id = aws_eip.nat[0].id
}

# Public Route Table - Routes traffic to Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-public-rt"
    Type = "Public"
  })
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table - Routes traffic through NAT Instance
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Add route to NAT Instance if enabled
  dynamic "route" {
    for_each = var.enable_nat_instance ? [1] : []
    content {
      cidr_block           = "0.0.0.0/0"
      network_interface_id = aws_instance.nat[0].primary_network_interface_id
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-private-rt"
    Type = "Private"
  })
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# VPC Flow Logs for network monitoring (optional)
resource "aws_flow_log" "vpc" {
  count           = var.enable_flow_logs ? 1 : 0
  iam_role_arn    = var.flow_logs_role_arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-vpc-flow-logs"
    Type = "Foundation"
  })
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc/flowlogs/${var.environment}"
  retention_in_days = 30

  tags = merge(var.common_tags, {
    Name = "${var.environment}-vpc-flow-logs"
    Type = "Foundation"
  })
} 