# ====================================
# IAM MODULE - OUTPUTS
# ====================================

# ====================================
# VPC FLOW LOGS IAM OUTPUTS
# ====================================

output "vpc_flow_logs_role_arn" {
  description = "ARN of the VPC Flow Logs IAM role"
  value       = var.enable_flow_logs ? aws_iam_role.vpc_flow_logs[0].arn : null
}

# ====================================
# ADMIN ROLE OUTPUTS
# ====================================

output "admin_role_arn" {
  description = "ARN of the admin IAM role"
  value       = var.enable_admin_role ? aws_iam_role.admin[0].arn : null
}

output "admin_instance_profile_name" {
  description = "Name of the admin instance profile"
  value       = var.enable_admin_role ? aws_iam_instance_profile.admin[0].name : null
}

output "admin_instance_profile_arn" {
  description = "ARN of the admin instance profile"
  value       = var.enable_admin_role ? aws_iam_instance_profile.admin[0].arn : null
}

# ====================================
# BASTION IAM OUTPUTS
# ====================================

output "bastion_role_arn" {
  description = "ARN of the bastion IAM role"
  value       = var.enable_bastion_role ? aws_iam_role.bastion[0].arn : null
}

output "bastion_instance_profile_name" {
  description = "Name of the bastion instance profile"
  value       = var.enable_bastion_role ? aws_iam_instance_profile.bastion[0].name : null
}

# ====================================
# APPLICATION TIER IAM OUTPUTS
# ====================================

output "app_tier_role_arn" {
  description = "ARN of the application tier IAM role"
  value       = var.enable_app_roles ? aws_iam_role.app_tier[0].arn : null
}

output "app_tier_instance_profile_name" {
  description = "Name of the application tier instance profile"
  value       = var.enable_app_roles ? aws_iam_instance_profile.app_tier[0].name : null
}

# ====================================
# LAMBDA IAM OUTPUTS
# ====================================

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = var.enable_lambda_roles ? aws_iam_role.lambda_execution[0].arn : null
}

# ====================================
# IAM MODULE SUMMARY
# ====================================

output "iam_summary" {
  description = "Summary of IAM resources created"
  value = {
    environment          = var.environment
    vpc_flow_logs_enabled = var.enable_flow_logs
    admin_role_enabled   = var.enable_admin_role
    bastion_role_enabled = var.enable_bastion_role
    app_roles_enabled    = var.enable_app_roles
    lambda_roles_enabled = var.enable_lambda_roles
  }
}

# ====================================
# FUTURE OUTPUTS
# ====================================
# Additional outputs can be added here for:
# - EC2 instance profile ARNs
# - Lambda execution role ARNs
# - ECS task role ARNs
# - S3 access role ARNs
# etc. 