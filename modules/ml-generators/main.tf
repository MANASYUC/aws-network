# ====================================
# ML DATA GENERATORS MODULE
# ====================================
# Web servers and traffic generators for ML training data
# ====================================

# ====================================
# WEB SERVER (Target for traffic)
# ====================================

resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.web_server_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.web_server.id]

  user_data = templatefile("${path.module}/scripts/web-server-setup.sh", {
    environment = var.environment
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-ml-web-server"
    Type = "WebServer"
    Role = "ML-Target"
  })
}

# ====================================
# TRAFFIC GENERATOR (Private subnet)
# ====================================

resource "aws_instance" "traffic_generator" {
  ami                    = var.ami_id
  instance_type          = var.traffic_gen_type
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.traffic_generator.id]

  user_data = templatefile("${path.module}/scripts/traffic-generator-setup.sh", {
    target_web_server = aws_instance.web_server.private_ip
    environment       = var.environment
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-ml-traffic-generator"
    Type = "TrafficGenerator"
    Role = "ML-DataGen"
  })

  depends_on = [aws_instance.web_server]
}

# ====================================
# SECURITY GROUPS
# ====================================

# Web Server Security Group
resource "aws_security_group" "web_server" {
  name        = "${var.environment}-ml-web-server-sg"
  description = "Security group for ML web server"
  vpc_id      = var.vpc_id

  # HTTP from anywhere (for traffic generation)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH from admin
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }

  # Custom app port
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-ml-web-server-sg"
  })
}

# Traffic Generator Security Group
resource "aws_security_group" "traffic_generator" {
  name        = "${var.environment}-ml-traffic-gen-sg"
  description = "Security group for ML traffic generator"
  vpc_id      = var.vpc_id

  # SSH from admin
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }

  # Outbound for traffic generation
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-ml-traffic-gen-sg"
  })
} 