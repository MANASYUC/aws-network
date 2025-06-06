# ====================================
# IAM MODULE - IDENTITY AND ACCESS MANAGEMENT
# ====================================
# This module creates IAM roles and policies for:
# - VPC Flow Logs
# - Admin Role (EC2 + S3 access)
# - Bastion Host
# - Application Roles
# - Lambda Roles
# ====================================

# ====================================
# VPC FLOW LOGS IAM RESOURCES
# ====================================

resource "aws_iam_role" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.environment}-vpc-flow-logs-role"

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

  tags = merge(var.common_tags, {
    Name    = "${var.environment}-vpc-flow-logs-role"
    Type    = "IAM"
    Purpose = "VPC Flow Logs"
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.environment}-vpc-flow-logs-policy"
  role  = aws_iam_role.vpc_flow_logs[0].id

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

# ====================================
# ADMIN ROLE - EC2 + S3 ACCESS
# ====================================

resource "aws_iam_role" "admin" {
  count = var.enable_admin_role ? 1 : 0
  name  = "${var.environment}-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name    = "${var.environment}-admin-role"
    Type    = "IAM"
    Purpose = "Admin Access"
  })
}

resource "aws_iam_instance_profile" "admin" {
  count = var.enable_admin_role ? 1 : 0
  name  = "${var.environment}-admin-profile"
  role  = aws_iam_role.admin[0].name
}

resource "aws_iam_role_policy" "admin" {
  count = var.enable_admin_role ? 1 : 0
  name  = "${var.environment}-admin-policy"
  role  = aws_iam_role.admin[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ec2:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# ====================================
# BASTION HOST ROLE
# ====================================

resource "aws_iam_role" "bastion" {
  count = var.enable_bastion_role ? 1 : 0
  name  = "${var.environment}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name    = "${var.environment}-bastion-role"
    Type    = "IAM"
    Purpose = "Bastion Host"
  })
}

resource "aws_iam_instance_profile" "bastion" {
  count = var.enable_bastion_role ? 1 : 0
  name  = "${var.environment}-bastion-profile"
  role  = aws_iam_role.bastion[0].name
}

resource "aws_iam_role_policy" "bastion" {
  count = var.enable_bastion_role ? 1 : 0
  name  = "${var.environment}-bastion-policy"
  role  = aws_iam_role.bastion[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# ====================================
# EC2 APPLICATION ROLES (Future use)
# ====================================

resource "aws_iam_role" "ec2_app_role" {
  count = var.enable_app_roles ? 1 : 0
  name  = "${var.environment}-ec2-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name    = "${var.environment}-ec2-app-role"
    Type    = "IAM"
    Purpose = "EC2-Application-Access"
  })
}

resource "aws_iam_instance_profile" "ec2_app_profile" {
  count = var.enable_app_roles ? 1 : 0
  name  = "${var.environment}-ec2-app-profile"
  role  = aws_iam_role.ec2_app_role[0].name

  tags = var.common_tags
} 