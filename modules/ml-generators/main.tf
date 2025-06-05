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
  key_name              = var.key_name
  subnet_id             = var.public_subnet_ids[0]
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
  key_name              = var.key_name
  subnet_id             = var.private_subnet_ids[0]
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
    cidr_blocks = ["10.0.0.0/16"]  # VPC only
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

# ====================================
# CLOUDWATCH LOGS (FREE TIER OPTIMIZED)
# ====================================

resource "aws_cloudwatch_log_group" "ml_logs" {
  count             = var.enable_cloudwatch ? 1 : 0
  name              = "/aws/ec2/${var.environment}-ml-data-generator"
  
  # OPTIMIZATION 3: Minimal retention for application logs
  retention_in_days = 1  # Export to S3 daily, keep minimal in CloudWatch
  
  tags = merge(var.tags, {
    Name = "${var.environment}-ml-logs"
    Purpose = "ML-Training-Events-Only"
  })
}

# OPTIMIZATION 4: Add filtered log streams for specific ML events
resource "aws_cloudwatch_log_group" "ml_training_events" {
  count             = var.enable_cloudwatch ? 1 : 0
  name              = "/aws/ml/${var.environment}-training-events"
  retention_in_days = 1
  
  tags = merge(var.tags, {
    Name = "${var.environment}-ml-training-events"
    Purpose = "Filtered-ML-Events"
  })
}

# ====================================
# VPC FLOW LOGS (FREE TIER OPTIMIZED)
# ====================================

resource "aws_flow_log" "ml_vpc_flow" {
  count           = var.enable_flow_logs ? 1 : 0
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  
  # COMPREHENSIVE TRAFFIC: Capture both normal and abnormal patterns
  # Essential for anomaly detection - need baseline + anomalies
  traffic_type    = "ALL"  # Changed back to ALL for comprehensive ML training
  
  vpc_id          = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.environment}-ml-vpc-flow-logs"
    Purpose = "Comprehensive-Anomaly-Detection"
    DataType = "Normal-and-Anomalous-Patterns"
  })
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc/${var.environment}-flow-logs"
  
  # OPTIMIZATION 2: Minimal retention for free tier
  retention_in_days = 1  # Keep only 1 day in CloudWatch
  
  tags = merge(var.tags, {
    Name = "${var.environment}-ml-flow-logs"
    OptimizedFor = "FreeTier"
  })
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.environment}-ml-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.environment}-ml-flow-logs-policy"
  role  = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
} 