# ====================================
# AWS NETWORK INFRASTRUCTURE - ROOT OUTPUTS
# ====================================

# ====================================
# FOUNDATION LAYER OUTPUTS
# CORE LAYER OUTPUTS
# ====================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.core.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.core.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.core.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.core.private_subnet_ids
}

output "nat_instance_info" {
  description = "NAT Instance information"
  value = var.enable_nat_instance ? {
    instance_id       = module.core.nat_instance_id
    private_ip        = module.core.nat_instance_private_ip
    public_ip         = module.core.nat_public_ip
    security_group_id = module.core.nat_security_group_id
  } : null
}

# ====================================
# PLATFORM LAYER OUTPUTS
# ====================================

output "bastion_connection_info" {
  description = "Information for connecting to the bastion host"
  value = var.enable_bastion ? {
    instance_id = module.platform.bastion_instance_id
    public_ip   = module.platform.bastion_public_ip
    private_ip  = module.platform.bastion_private_ip
    ssh_command = module.platform.bastion_ssh_command
  } : null
}

output "security_groups" {
  description = "Security group information"
  value       = module.platform.security_groups_summary
}

# ====================================
# APPLICATION TIER OUTPUTS (CONDITIONAL)
# ====================================

output "web_tier_info" {
  description = "Web tier deployment information"
  value = var.enable_web_tier ? {
    enabled = true
    count   = var.web_instance_count
    type    = var.web_instance_type
  } : { enabled = false }
}

output "app_tier_info" {
  description = "Application tier deployment information"
  value = var.enable_app_tier ? {
    enabled = true
    count   = var.app_instance_count
    type    = var.app_instance_type
  } : { enabled = false }
}

output "data_tier_info" {
  description = "Data tier deployment information"
  value = var.enable_data_tier ? {
    enabled = true
    type    = var.db_instance_type
  } : { enabled = false }
}

# ====================================
# DEPLOYMENT SUMMARY
# ====================================

output "deployment_summary" {
  description = "Complete summary of deployed infrastructure"
  value = {
    environment = var.environment
    region      = var.aws_region
    vpc_id      = module.core.vpc_id
    vpc_cidr    = module.core.vpc_cidr_block

    # Layer deployment status
    core_deployed      = true
    platform_deployed  = true
    web_tier_deployed  = var.enable_web_tier
    app_tier_deployed  = var.enable_app_tier
    data_tier_deployed = var.enable_data_tier

    # Key resources
    bastion_enabled      = var.enable_bastion
    bastion_public_ip    = var.enable_bastion ? module.platform.bastion_public_ip : null
    nat_instance_enabled = var.enable_nat_instance
    nat_instance_ip      = var.enable_nat_instance ? module.core.nat_public_ip : null
    public_subnets       = length(module.core.public_subnet_ids)
    private_subnets      = length(module.core.private_subnet_ids)

    # Access information
    ssh_key_name      = var.existing_key_name
    admin_access_from = var.admin_cidr_blocks
  }
}

# ====================================
# QUICK REFERENCE
# ====================================

output "quick_reference" {
  description = "Quick reference for common operations"
  value = var.enable_bastion ? {
    bastion_ssh      = "ssh -i ${var.existing_key_name}.pem ec2-user@${module.platform.bastion_public_ip}"
    nat_instance_ssh = var.enable_nat_instance ? "ssh -i ${var.existing_key_name}.pem ec2-user@${module.core.nat_public_ip}" : "NAT Instance disabled"
    view_vpc         = "aws ec2 describe-vpcs --vpc-ids ${module.core.vpc_id}"
    view_subnets     = "aws ec2 describe-subnets --filters Name=vpc-id,Values=${module.core.vpc_id}"
    view_instances   = "aws ec2 describe-instances --filters Name=vpc-id,Values=${module.core.vpc_id}"
    } : {
    message = "Enable bastion host to get SSH access information"
  }
}
