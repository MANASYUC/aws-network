# ====================================
# ML-FOCUSED INFRASTRUCTURE OUTPUTS
# ====================================

# ====================================
# NETWORK INFORMATION
# ====================================

output "vpc_info" {
  description = "VPC and networking information"
  value = {
    vpc_id   = module.foundation.vpc_id
    vpc_cidr = module.foundation.vpc_cidr_block
    subnets = {
      public = {
        ids   = module.foundation.public_subnet_ids
        cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
      }
      private = {
        ids   = module.foundation.private_subnet_ids
        cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
      }
    }
  }
}

# ====================================
# ML DATA GENERATION OUTPUTS
# ====================================

output "ml_data_generators" {
  description = "ML data generation infrastructure"
  value = {
    web_server = {
      public_ip  = module.ml_data_generators.web_server_public_ip
      private_ip = module.ml_data_generators.web_server_private_ip
      url        = "http://${module.ml_data_generators.web_server_public_ip}/"
      api_url    = "http://${module.ml_data_generators.web_server_public_ip}:8080/api/users"
    }
    traffic_generator = {
      private_ip = module.ml_data_generators.traffic_generator_private_ip
    }
  }
}

# ====================================
# NAT INSTANCE INFO
# ====================================

output "nat_instance_info" {
  description = "NAT instance information for cost-effective private subnet access"
  value = {
    public_ip   = module.foundation.nat_public_ip
    private_ip  = module.foundation.nat_instance_private_ip
    instance_id = module.foundation.nat_instance_id
  }
}

# ====================================
# BASTION HOST (If Enabled)
# ====================================

output "bastion_host_info" {
  description = "Bastion host information"
  value = var.enable_bastion && length(module.bastion_host) > 0 ? {
    public_ip   = module.bastion_host[0].bastion_public_ip
    instance_id = module.bastion_host[0].bastion_instance_id
    ssh_command = "ssh -i your-key.pem ec2-user@${module.bastion_host[0].bastion_public_ip}"
  } : null
}

# ====================================
# S3 STORAGE FOR ML DATASETS
# ====================================

output "s3_buckets" {
  description = "S3 buckets for ML dataset storage"
  value = {
    app_storage_bucket = module.ml_storage.app_storage_bucket_id
    logs_bucket        = module.ml_storage.logs_bucket_id
    ml_dataset_path    = "s3://${module.ml_storage.app_storage_bucket_id}/ml-datasets/anomaly-detection/"
  }
}

# ====================================
# ML DATASET INFORMATION
# ====================================

output "ml_dataset_info" {
  description = "Information about ML datasets and collection"
  value = {
    bucket_name     = module.ml_storage.app_storage_bucket_id
    data_types      = "Network,Authentication,System,Application,TimeSeries"
    collection_mode = "Enhanced-Anomaly-Detection"
    access_command  = "aws s3 ls s3://${module.ml_storage.app_storage_bucket_id}/ml-datasets/"
  }
}

# ====================================
# MONITORING & COMMANDS
# ====================================

output "monitoring_commands" {
  description = "Useful commands for monitoring and data collection"
  value = {
    ssh_web_server    = "ssh -i your-key.pem ec2-user@${module.ml_data_generators.web_server_public_ip}"
    view_flow_logs    = var.enable_flow_logs ? "aws logs get-log-events --log-group-name ${module.ml_data_generators.flow_logs_group_name}" : "Flow logs not enabled"
    view_ml_logs      = var.enable_cloudwatch_logs ? "aws logs get-log-events --log-group-name ${module.ml_data_generators.ml_logs_group_name}" : "CloudWatch logs not enabled"
    test_web_app      = "curl http://${module.ml_data_generators.web_server_public_ip}/"
    test_api          = "curl http://${module.ml_data_generators.web_server_public_ip}:8080/api/users"
    download_datasets = "aws s3 sync s3://${module.ml_storage.app_storage_bucket_id}/ml-datasets/ ./ml-data/"
    check_s3_usage    = "aws s3 ls s3://${module.ml_storage.app_storage_bucket_id} --recursive --human-readable --summarize"
  }
}

# ====================================
# SECURITY INFORMATION
# ====================================

output "security_groups" {
  description = "Security group information"
  value = {
    web_server_sg        = module.ml_data_generators.web_server_security_group_id
    traffic_generator_sg = module.ml_data_generators.traffic_generator_security_group_id
  }
}

# ====================================
# COST SUMMARY
# ====================================

output "cost_summary" {
  description = "Estimated monthly costs for ML-focused deployment"
  value = {
    mode           = "ml-focused"
    estimated_cost = "$25-30/month"
    optimization   = "NAT Instance (vs NAT Gateway), t3.micro instances, minimal log retention"
    cost_breakdown = {
      instances     = "3x t3.micro (~$21/month)"
      nat_instance  = "1x t3.nano (~$3/month)"
      storage       = "S3 Standard (~$1-5/month depending on usage)"
      data_transfer = "Free tier covers typical ML training data volume"
    }
  }
}

# ====================================
# QUICK ACCESS GUIDE
# ====================================

output "quick_access" {
  description = "Quick access information for ML-focused deployment"
  value = {
    web_app_url     = "http://${module.ml_data_generators.web_server_public_ip}/"
    api_endpoint    = "http://${module.ml_data_generators.web_server_public_ip}:8080/api/users"
    ssh_access      = "ssh -i your-key.pem ec2-user@${module.ml_data_generators.web_server_public_ip}"
    bastion_access  = var.enable_bastion && length(module.bastion_host) > 0 ? "ssh -i your-key.pem ec2-user@${module.bastion_host[0].bastion_public_ip}" : "Bastion not enabled"
    data_collection = "Automated traffic generation and anomaly detection data"
  }
}

# ====================================
# DEPLOYMENT SUMMARY
# ====================================

output "deployment_summary" {
  description = "Complete deployment summary"
  value = {
    mode        = "ml-focused"
    environment = var.environment
    region      = var.region
    vpc_cidr    = module.foundation.vpc_cidr_block

    deployed_services = {
      foundation_network  = "deployed"
      ml_data_generators  = "deployed"
      enhanced_monitoring = var.enable_enhanced_monitoring ? "enabled" : "disabled"
      bastion_host        = var.enable_bastion ? "enabled" : "disabled"
      s3_storage          = "deployed"
    }

    data_collection = {
      vpc_flow_logs   = var.enable_flow_logs ? "enabled" : "disabled"
      cloudwatch_logs = var.enable_cloudwatch_logs ? "enabled" : "disabled"
      log_retention   = "${var.log_retention_days} days"
    }

    ml_capabilities = {
      anomaly_detection = "comprehensive-traffic-patterns"
      data_types        = "network,authentication,system,application"
      export_ready      = true
    }
  }
} 