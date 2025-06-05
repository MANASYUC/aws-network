# ====================================
# ML-FOCUSED MODE OUTPUTS
# ====================================
# Enhanced outputs for comprehensive ML training data

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
    public_ip    = module.ml_data_generators.web_server_public_ip
    private_ip   = module.ml_data_generators.web_server_private_ip
    instance_id  = module.ml_data_generators.web_server_instance_id
    ssh_command  = "ssh -i your-key.pem ec2-user@${module.ml_data_generators.web_server_public_ip}"
  }
}

output "traffic_generator_info" {
  description = "Traffic generator instance information"
  value = {
    private_ip   = module.ml_data_generators.traffic_generator_private_ip
    instance_id  = module.ml_data_generators.traffic_generator_instance_id
    status       = "Generating comprehensive ML training data"
    data_types   = "Network, Authentication, System, Application, Time-series"
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

output "bastion_host_info" {
  description = "Bastion host information (if enabled)"
  value = var.enable_bastion && length(module.bastion_host) > 0 ? {
    public_ip   = module.bastion_host[0].bastion_public_ip
    instance_id = module.bastion_host[0].bastion_instance_id
    ssh_command = "ssh -i your-key.pem ec2-user@${module.bastion_host[0].bastion_public_ip}"
  } : "Bastion host not enabled"
}

# ====================================
# ML DATA STORAGE
# ====================================

output "s3_buckets" {
  description = "S3 buckets for ML data storage"
  value = {
    app_storage_bucket = module.ml_storage.app_storage_bucket
    logs_bucket       = module.ml_storage.logs_bucket
    ml_dataset_path   = "s3://${module.ml_storage.app_storage_bucket}/ml-datasets/anomaly-detection/"
  }
}

output "ml_dataset_info" {
  description = "ML dataset collection information"
  value = {
    bucket_name      = module.ml_storage.app_storage_bucket
    dataset_types    = ["network-patterns", "authentication-events", "system-behavior", "application-metrics", "time-series"]
    export_schedule  = var.export_schedule
    retention_days   = var.s3_retention_days
    access_command   = "aws s3 ls s3://${module.ml_storage.app_storage_bucket}/ml-datasets/"
  }
}

# ====================================
# MONITORING AND LOGGING
# ====================================

output "cloudwatch_logs" {
  description = "CloudWatch log groups"
  value = {
    ml_logs          = module.ml_data_generators.cloudwatch_log_group
    vpc_flow_logs    = module.ml_data_generators.vpc_flow_log_group
    retention_days   = var.log_retention_days
  }
}

output "monitoring_commands" {
  description = "Commands to monitor ML data collection"
  value = {
    view_flow_logs     = "aws logs filter-log-events --log-group-name '/aws/vpc/ml-dev-flow-logs'"
    view_ml_logs       = "aws logs filter-log-events --log-group-name '/aws/ec2/ml-dev-ml-data-generator'"
    download_datasets  = "aws s3 sync s3://${module.ml_storage.app_storage_bucket}/ml-datasets/ ./ml-data/"
    check_s3_usage     = "aws s3 ls s3://${module.ml_storage.app_storage_bucket} --recursive --human-readable --summarize"
  }
}

# ====================================
# QUICK ACCESS COMMANDS
# ====================================

output "ssh_commands" {
  description = "SSH commands for quick access"
  value = {
    web_server = "ssh -i your-key.pem ec2-user@${module.ml_data_generators.web_server_public_ip}"
    nat_instance = "ssh -i your-key.pem ec2-user@${module.ml_network.nat_instance_public_ip}"
    bastion_host = var.enable_bastion && length(module.bastion_host) > 0 ? "ssh -i your-key.pem ec2-user@${module.bastion_host[0].bastion_public_ip}" : "Bastion not enabled"
  }
  sensitive = false
}

output "web_server_url" {
  description = "Web server URL for testing"
  value = "http://${module.ml_data_generators.web_server_public_ip}"
}

# ====================================
# ML TRAINING READY OUTPUTS
# ====================================

output "ml_training_info" {
  description = "Information for ML model training"
  value = {
    data_ready        = "Comprehensive anomaly detection dataset"
    normal_patterns   = "80% baseline behavior (sampled)"
    anomaly_patterns  = "20% attack/unusual patterns (complete)"
    feature_vectors   = "JSON format with multi-dimensional features"
    data_layers       = ["Network", "Authentication", "System", "Application", "Time-series"]
    ml_algorithms     = ["Isolation Forest", "One-Class SVM", "Autoencoders", "LSTM", "Random Forest"]
    next_steps        = [
      "Download datasets from S3",
      "Analyze data patterns",
      "Build anomaly detection models",
      "Train on normal vs anomalous patterns"
    ]
  }
}

# ====================================
# DEPLOYMENT SUMMARY
# ====================================

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    mode                = "ml-focused"
    environment         = var.environment
    region              = var.region
    vpc_cidr           = module.ml_network.vpc_cidr
    instances_count    = var.enable_bastion ? 4 : 3  # Web + Traffic + NAT + optional Bastion
    estimated_cost     = "$15-25/month"
    data_collection    = "Comprehensive anomaly detection training data"
    ml_capabilities    = "Ready for supervised and unsupervised ML"
    traffic_intensity  = var.traffic_intensity
    data_export       = var.enable_data_export ? "Enabled" : "Disabled"
    bastion_host      = var.enable_bastion ? "Enabled" : "Disabled"
    next_steps        = [
      "Monitor data collection in CloudWatch",
      "Download ML datasets from S3",
      "SSH into instances to examine logs",
      "Start building anomaly detection models"
    ]
  }
} 