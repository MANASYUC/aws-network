# ====================================
# SIMPLIFIED MODE OUTPUTS
# ====================================
# Essential outputs for simplified ML data generation

# ====================================
# NETWORK INFORMATION
# ====================================

output "vpc_info" {
  description = "VPC configuration details"
  value = {
    vpc_id   = module.ml_network.vpc_id
    vpc_cidr = module.ml_network.vpc_cidr
    public_subnets = {
      ids   = module.ml_network.public_subnet_ids
      cidrs = module.ml_network.public_subnet_cidrs
    }
    private_subnets = {
      ids   = module.ml_network.private_subnet_ids
      cidrs = module.ml_network.private_subnet_cidrs
    }
  }
}

# ====================================
# INSTANCE ACCESS
# ====================================

output "web_server_info" {
  description = "Web server access information"
  value = {
    public_ip   = module.ml_data_generators.web_server_public_ip
    private_ip  = module.ml_data_generators.web_server_private_ip
    instance_id = module.ml_data_generators.web_server_instance_id
    ssh_command = "ssh -i your-key.pem ec2-user@${module.ml_data_generators.web_server_public_ip}"
  }
}

output "traffic_generator_info" {
  description = "Traffic generator instance information"
  value = {
    private_ip  = module.ml_data_generators.traffic_generator_private_ip
    instance_id = module.ml_data_generators.traffic_generator_instance_id
    status      = "Running in private subnet, generating ML training data"
  }
}

output "nat_instance_info" {
  description = "NAT instance information"
  value = {
    public_ip   = module.ml_network.nat_instance_public_ip
    private_ip  = module.ml_network.nat_instance_private_ip
    instance_id = module.ml_network.nat_instance_id
  }
}

# ====================================
# DATA STORAGE
# ====================================

output "s3_buckets" {
  description = "S3 buckets for ML data storage"
  value = {
    app_storage_bucket = module.ml_storage.app_storage_bucket
    logs_bucket        = module.ml_storage.logs_bucket
  }
}

# ====================================
# MONITORING
# ====================================

output "cloudwatch_logs" {
  description = "CloudWatch log groups"
  value = {
    ml_logs       = module.ml_data_generators.cloudwatch_log_group
    vpc_flow_logs = module.ml_data_generators.vpc_flow_log_group
  }
}

# ====================================
# QUICK ACCESS COMMANDS
# ====================================

output "ssh_commands" {
  description = "SSH commands for quick access"
  value = {
    web_server   = "ssh -i your-key.pem ec2-user@${module.ml_data_generators.web_server_public_ip}"
    nat_instance = "ssh -i your-key.pem ec2-user@${module.ml_network.nat_instance_public_ip}"
  }
  sensitive = false
}

output "web_server_url" {
  description = "Web server URL for testing"
  value       = "http://${module.ml_data_generators.web_server_public_ip}"
}

# ====================================
# DEPLOYMENT SUMMARY
# ====================================

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    mode            = "simplified"
    environment     = var.environment
    region          = var.region
    vpc_cidr        = module.ml_network.vpc_cidr
    instances_count = 3 # Web server + Traffic generator + NAT
    estimated_cost  = "$0-15/month (Free Tier optimized)"
    data_collection = "Basic ML training data generation"
    next_steps = [
      "SSH into web server to view logs",
      "Check S3 buckets for ML data",
      "Monitor CloudWatch logs",
      "Upgrade to ml-focused mode for enhanced features"
    ]
  }
} 