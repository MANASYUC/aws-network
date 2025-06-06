# ====================================
# PLATFORM MODULE - OUTPUTS  
# ====================================

# Security Group IDs
output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion.id
}

output "web_tier_security_group_id" {
  description = "ID of the web tier security group"
  value       = aws_security_group.web_tier.id
}

output "app_tier_security_group_id" {
  description = "ID of the application tier security group"
  value       = aws_security_group.app_tier.id
}

output "db_tier_security_group_id" {
  description = "ID of the database tier security group"
  value       = aws_security_group.db_tier.id
}

# Bastion Host Information
output "bastion_instance_id" {
  description = "ID of the bastion host instance"
  value       = var.enable_bastion ? aws_instance.bastion[0].id : null
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = var.enable_bastion ? aws_instance.bastion[0].public_ip : null
}

output "bastion_private_ip" {
  description = "Private IP address of the bastion host"
  value       = var.enable_bastion ? aws_instance.bastion[0].private_ip : null
}

output "bastion_ssh_command" {
  description = "SSH command to connect to the bastion host"
  value       = var.enable_bastion ? "ssh -i ${var.create_bastion_key ? aws_key_pair.bastion[0].key_name : var.existing_key_name}.pem ec2-user@${aws_instance.bastion[0].public_ip}" : null
}

# Security Group Rules Summary
output "security_groups_summary" {
  description = "Summary of all security groups created"
  value = {
    bastion = {
      id          = aws_security_group.bastion.id
      name        = aws_security_group.bastion.name
      description = aws_security_group.bastion.description
    }
    web_tier = {
      id          = aws_security_group.web_tier.id
      name        = aws_security_group.web_tier.name
      description = aws_security_group.web_tier.description
    }
    app_tier = {
      id          = aws_security_group.app_tier.id
      name        = aws_security_group.app_tier.name
      description = aws_security_group.app_tier.description
    }
    db_tier = {
      id          = aws_security_group.db_tier.id
      name        = aws_security_group.db_tier.name
      description = aws_security_group.db_tier.description
    }
  }
}

# Platform Resources Summary
output "platform_summary" {
  description = "Summary of platform resources"
  value = {
    environment          = var.environment
    bastion_enabled      = var.enable_bastion
    bastion_instance_id  = var.enable_bastion ? aws_instance.bastion[0].id : null
    bastion_public_ip    = var.enable_bastion ? aws_instance.bastion[0].public_ip : null
    security_groups      = 4
    network_acls_enabled = var.enable_network_acls
    logging_enabled      = var.enable_logging
  }
}
