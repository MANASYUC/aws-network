# ====================================
# SIMPLIFIED MODE OUTPUTS
# ====================================
# Essential outputs for simplified ML data generation

# ====================================
# NETWORK INFORMATION
# ====================================

output "vpc_info" {
  description = "VPC information"
  value = {
    vpc_id               = module.ml_network.vpc_id
    public_subnet_ids    = module.ml_network.public_subnet_ids
    private_subnet_ids   = module.ml_network.private_subnet_ids
    internet_gateway_id  = module.ml_network.internet_gateway_id
  }
}

# ====================================
# INSTANCE ACCESS
# ====================================

output "instances" {
  description = "EC2 instance information"
  value = {
    web_server = {
      id         = module.ml_data_generators.web_server_id
      public_ip  = module.ml_data_generators.web_server_public_ip
      private_ip = module.ml_data_generators.web_server_private_ip
    }
    traffic_generator = {
      id         = module.ml_data_generators.traffic_generator_id
      private_ip = module.ml_data_generators.traffic_generator_private_ip
    }
    nat_instance = module.ml_network.nat_instance_info
  }
}

# ====================================
# DATA STORAGE
# ====================================

output "ml_storage" {
  description = "ML data storage information"
  value = {
    bucket_name = module.ml_storage.bucket_name
    bucket_arn  = module.ml_storage.bucket_arn
  }
}

# ====================================
# SECURITY GROUPS
# ====================================

output "security_groups" {
  description = "Security group information"
  value = {
    web_server        = module.ml_data_generators.web_server_security_group_id
    traffic_generator = module.ml_data_generators.traffic_generator_security_group_id
  }
}

# ====================================
# SSH CONNECTION COMMANDS
# ====================================

output "ssh_commands" {
  description = "SSH connection commands"
  value = {
    web_server = "ssh -i your-key.pem ec2-user@${module.ml_data_generators.web_server_public_ip}"
    nat_instance = "ssh -i your-key.pem ec2-user@${module.ml_network.nat_instance_info.public_ip}"
  }
}

# ====================================
# DEPLOYMENT SUMMARY
# ====================================

output "deployment_summary" {
  description = "Deployment summary for simplified mode"
  value = {
    mode             = "simplified"
    instance_count   = 3
    estimated_cost   = "$0-15/month (Free Tier optimized)"
    data_collection  = "Basic ML training data"
    
    next_steps = [
      "Connect to instances using SSH commands above",
      "Monitor data generation in S3 bucket",
      "Run for ~30 hours to collect sufficient data",
      "Run 'terraform destroy' when done learning"
    ]
  }
} 