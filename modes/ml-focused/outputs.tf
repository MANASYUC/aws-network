# ====================================
# ML-FOCUSED INFRASTRUCTURE OUTPUTS
# ====================================

# ====================================
# NETWORK INFORMATION
# ====================================

output "vpc_info" {
  description = "VPC configuration details"
  value = {
    vpc_id   = module.foundation.vpc_id
    vpc_cidr = "10.0.0.0/16"
    public_subnets = {
      ids   = module.foundation.public_subnet_ids
      cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
    }
    private_subnets = {
      ids   = module.foundation.private_subnet_ids
      cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
    }
  }
}

# ====================================
# ML DATA GENERATION OUTPUTS
# ====================================

output "ml_infrastructure" {
  description = "ML data generation infrastructure"
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
    nat_instance = module.foundation.nat_instance_info
    bastion_host = var.enable_bastion ? {
      id         = module.bastion_host[0].bastion_instance_id
      public_ip  = module.bastion_host[0].bastion_public_ip
      private_ip = module.bastion_host[0].bastion_private_ip
    } : null
  }
}

# ====================================
# S3 STORAGE FOR ML DATASETS
# ====================================

output "ml_storage" {
  description = "ML data storage configuration"
  value = {
    bucket_name = module.ml_storage.bucket_name
    bucket_arn  = module.ml_storage.bucket_arn
    data_types  = ["network", "authentication", "system", "application", "timeseries"]
  }
}

# ====================================
# COST SUMMARY
# ====================================

output "cost_summary" {
  description = "Estimated monthly costs for ML-focused deployment"
  value = {
    estimated_cost = "$25-30/month"
    instance_hours = "3-4 instances running"
    cost_breakdown = {
      ec2_instances = "$20-25 (t3.micro/nano instances)"
      s3_storage    = "$2-3 (ML datasets)"
      data_transfer = "Free tier covers typical ML training data volume"
    }
  }
}

# ====================================
# SSH COMMANDS
# ====================================

output "ssh_commands" {
  description = "SSH access commands for instances"
  value = {
    web_server   = "ssh -i your-key.pem ec2-user@${module.ml_data_generators.web_server_public_ip}"
    nat_instance = "ssh -i your-key.pem ec2-user@${module.foundation.nat_instance_info.public_ip}"
    bastion_host = var.enable_bastion ? "ssh -i your-key.pem ec2-user@${module.bastion_host[0].bastion_public_ip}" : "Bastion not enabled"
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
# ML DATA COLLECTION STATUS
# ====================================

output "data_collection_info" {
  description = "ML data collection configuration"
  value = {
    collection_status = "Direct S3 storage enabled"
    data_pipeline    = "EC2 → S3 (optimized for ML training)"
    storage_format   = "JSON, CSV, Parquet supported"
    retention_days   = var.s3_retention_days
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
    data_collection = "Direct S3 storage for ML training data"
  }
} 