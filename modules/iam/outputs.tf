# ====================================
# IAM MODULE - OUTPUTS
# ====================================

# ====================================
# VPC FLOW LOGS IAM OUTPUTS
# ====================================

output "vpc_flow_logs_role_arn" {
  description = "ARN of the VPC Flow Logs role"
  value       = var.enable_flow_logs ? aws_iam_role.vpc_flow_logs[0].arn : null
}

# ====================================
# ADMIN IAM OUTPUTS
# ====================================

output "admin_role_arn" {
  description = "ARN of the admin role"
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
  description = "ARN of the bastion role"
  value       = var.enable_bastion_role ? aws_iam_role.bastion[0].arn : null
}

output "bastion_instance_profile_name" {
  description = "Name of the bastion instance profile"
  value       = var.enable_bastion_role ? aws_iam_instance_profile.bastion[0].name : null
}

# ====================================
# APPLICATION IAM OUTPUTS
# ====================================

output "app_role_arn" {
  description = "ARN of the application role"
  value       = var.enable_app_roles ? aws_iam_role.ec2_app_role[0].arn : null
}

output "app_instance_profile_name" {
  description = "Name of the application instance profile"
  value       = var.enable_app_roles ? aws_iam_instance_profile.ec2_app_profile[0].name : null
}

# ====================================
# IAM MODULE SUMMARY
# ====================================

output "iam_summary" {
  description = "Summary of IAM resources created"
  value = {
    flow_logs_enabled     = var.enable_flow_logs
    admin_role_enabled    = var.enable_admin_role
    bastion_role_enabled  = var.enable_bastion_role
    app_roles_enabled     = var.enable_app_roles
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