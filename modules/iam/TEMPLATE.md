# IAM Role Template

## Quick Guide to Add New IAM Roles

### 1. Add Variable (variables.tf)
```hcl
variable "enable_[ROLE_NAME]_role" {
  description = "Enable [ROLE_NAME] IAM role"
  type        = bool
  default     = false
}
```

### 2. Add Role Resources (main.tf)
```hcl
# ====================================
# [ROLE_NAME] ROLE
# ====================================

resource "aws_iam_role" "[ROLE_NAME]" {
  count = var.enable_[ROLE_NAME]_role ? 1 : 0
  name  = "${var.environment}-[ROLE_NAME]-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "[SERVICE].amazonaws.com"  # ec2, lambda, ecs-tasks, etc.
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-[ROLE_NAME]-role"
    Type = "IAM"
    Purpose = "[PURPOSE]"
  })
}

# Instance Profile (only for EC2 roles)
resource "aws_iam_instance_profile" "[ROLE_NAME]" {
  count = var.enable_[ROLE_NAME]_role ? 1 : 0
  name  = "${var.environment}-[ROLE_NAME]-profile"
  role  = aws_iam_role.[ROLE_NAME][0].name
}

# Role Policy
resource "aws_iam_role_policy" "[ROLE_NAME]" {
  count = var.enable_[ROLE_NAME]_role ? 1 : 0
  name  = "${var.environment}-[ROLE_NAME]-policy"
  role  = aws_iam_role.[ROLE_NAME][0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "[ACTIONS_HERE]"
        ]
        Effect   = "Allow"
        Resource = "[RESOURCE_ARN_OR_*]"
      }
    ]
  })
}
```

### 3. Add Outputs (outputs.tf)
```hcl
# ====================================
# [ROLE_NAME] IAM OUTPUTS
# ====================================

output "[ROLE_NAME]_role_arn" {
  description = "ARN of the [ROLE_NAME] IAM role"
  value       = var.enable_[ROLE_NAME]_role ? aws_iam_role.[ROLE_NAME][0].arn : null
}

output "[ROLE_NAME]_instance_profile_name" {
  description = "Name of the [ROLE_NAME] instance profile"
  value       = var.enable_[ROLE_NAME]_role ? aws_iam_instance_profile.[ROLE_NAME][0].name : null
}
```

### 4. Update main.tf (root level)
```hcl
module "iam" {
  # ... existing config
  enable_[ROLE_NAME]_role = var.enable_[FEATURE]
}
```

### 5. Use in Other Modules
```hcl
resource "aws_instance" "example" {
  iam_instance_profile = module.iam.[ROLE_NAME]_instance_profile_name
  # ... other config
}
```

## Common Service Principals
- `ec2.amazonaws.com` - EC2 instances
- `lambda.amazonaws.com` - Lambda functions
- `ecs-tasks.amazonaws.com` - ECS tasks
- `rds.amazonaws.com` - RDS services
- `s3.amazonaws.com` - S3 services

## Common Actions
- `"ec2:*"` - All EC2 actions
- `"s3:*"` - All S3 actions
- `"s3:GetObject", "s3:PutObject"` - Specific S3 actions
- `"logs:*"` - All CloudWatch Logs actions
- `"rds:Describe*"` - Read-only RDS actions 