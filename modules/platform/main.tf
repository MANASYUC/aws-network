# ====================================
# PLATFORM MODULE - SECURITY & MANAGEMENT
# ====================================
# This module creates platform services that run on top of the core:
# - Security Groups for different tiers
# - Bastion Host for secure access
# - Network ACLs for additional security
# - Key management and access controls
# ====================================

# ====================================
# SECURITY GROUPS
# ====================================

# Bastion Security Group - Entry point for admin access
resource "aws_security_group" "bastion" {
  name_prefix = "${var.environment}-bastion-"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  # SSH access from admin IPs only
  ingress {
    description = "SSH from admin IPs"
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
    Name = "${var.environment}-bastion-sg"
    Tier = "Platform"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Web Tier Security Group - Public-facing web servers
resource "aws_security_group" "web_tier" {
  name_prefix = "${var.environment}-web-tier-"
  description = "Security group for web tier"
  vpc_id      = var.vpc_id

  # HTTP access from anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access from bastion only
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
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
    Name = "${var.environment}-web-tier-sg"
    Tier = "Web"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Application Tier Security Group - Internal application servers
resource "aws_security_group" "app_tier" {
  name_prefix = "${var.environment}-app-tier-"
  description = "Security group for application tier"
  vpc_id      = var.vpc_id

  # Application port access from web tier
  ingress {
    description     = "App port from web tier"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier.id]
  }

  # SSH access from bastion only
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
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
    Name = "${var.environment}-app-tier-sg"
    Tier = "Application"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Database Tier Security Group - Database servers
resource "aws_security_group" "db_tier" {
  name_prefix = "${var.environment}-db-tier-"
  description = "Security group for database tier"
  vpc_id      = var.vpc_id

  # Database port access from app tier only
  ingress {
    description     = "Database port from app tier"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tier.id]
  }

  # SSH access from bastion only
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Allow outbound traffic for updates/patches
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-db-tier-sg"
    Tier = "Database"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ====================================
# BASTION HOST
# ====================================

# Key pair for bastion host (if creating new)
resource "aws_key_pair" "bastion" {
  count      = var.create_bastion_key ? 1 : 0
  key_name   = "${var.environment}-bastion-key"
  public_key = var.bastion_public_key

  tags = merge(var.common_tags, {
    Name = "${var.environment}-bastion-key"
    Type = "Platform"
  })
}

# Bastion Host Instance
resource "aws_instance" "bastion" {
  count                       = var.enable_bastion ? 1 : 0
  ami                         = var.bastion_ami_id
  instance_type               = var.bastion_instance_type
  key_name                    = var.existing_key_name != "" ? var.existing_key_name : aws_key_pair.bastion.key_name
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/user_data/bastion_setup.sh", {
    environment = var.environment
    log_group   = ""
  }))

  monitoring = var.enable_detailed_monitoring

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-bastion"
    Type = "Management"
    Role = "Bastion"
  })
}

# ====================================
# LOGGING & MONITORING
# ====================================

# ====================================
# NETWORK ACLs (Additional Security Layer)
# ====================================

# Custom Network ACL for additional security
resource "aws_network_acl" "platform" {
  count  = var.enable_network_acls ? 1 : 0
  vpc_id = var.vpc_id

  # Allow HTTP inbound
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Allow HTTPS inbound
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allow SSH from admin networks only
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.admin_cidr_blocks[0]
    from_port  = 22
    to_port    = 22
  }

  # Allow ephemeral ports for return traffic
  ingress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Allow all outbound traffic
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-platform-nacl"
    Type = "Platform"
  })
}

# Associate Network ACL with public subnets
resource "aws_network_acl_association" "public" {
  count          = var.enable_network_acls ? length(var.public_subnet_ids) : 0
  subnet_id      = var.public_subnet_ids[count.index]
  network_acl_id = aws_network_acl.platform.id
} 
