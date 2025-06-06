# ====================================
# MERGED INFRASTRUCTURE OUTPUTS
# ====================================
# Outputs for both simplified ML-focused and comprehensive learning modes
# ====================================

# ====================================
# DEPLOYMENT MODE INFORMATION
# ====================================

output "deployment_mode" {
  description = "Current deployment mode"
  value       = var.deployment_mode
}

output "deployed_modules" {
  description = "List of deployed modules based on mode"
  value = {
    mode = var.deployment_mode
    ml_modules = var.deployment_mode == "simplified" || var.deployment_mode == "ml-focused" ? [
      "ml-network",
      "ml-generators",
      "ml-security"
    ] : []
    full_modules = var.deployment_mode == "full" ? [
      "iam",
      "foundation",
      "platform",
      "web-tier (optional)",
      "app-tier (optional)",
      "data-tier (optional)"
    ] : []
  }
}

# ====================================
# NETWORK INFORMATION (CONDITIONAL)
# ====================================

output "vpc_id" {
  description = "ID of the VPC"
  value = var.deployment_mode == "full" ? (
    length(module.foundation) > 0 ? module.foundation[0].vpc_id : null
    ) : (
    length(module.ml_network) > 0 ? module.ml_network[0].vpc_id : null
  )
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value = var.deployment_mode == "full" ? (
    length(module.foundation) > 0 ? module.foundation[0].vpc_cidr_block : null
    ) : (
    length(module.ml_network) > 0 ? module.ml_network[0].vpc_cidr_block : null
  )
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = var.deployment_mode == "full" ? (
    length(module.foundation) > 0 ? module.foundation[0].public_subnet_ids : []
    ) : (
    length(module.ml_network) > 0 ? module.ml_network[0].public_subnet_ids : []
  )
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value = var.deployment_mode == "full" ? (
    length(module.foundation) > 0 ? module.foundation[0].private_subnet_ids : []
    ) : (
    length(module.ml_network) > 0 ? module.ml_network[0].private_subnet_ids : []
  )
}

# ====================================
# ML DATA GENERATION OUTPUTS (SIMPLIFIED/ML-FOCUSED MODES)
# ====================================

output "web_server_public_ip" {
  description = "Public IP of the ML web server (target)"
  value       = length(module.ml_data_generators) > 0 ? module.ml_data_generators[0].web_server_public_ip : null
}

output "web_server_private_ip" {
  description = "Private IP of the ML web server"
  value       = length(module.ml_data_generators) > 0 ? module.ml_data_generators[0].web_server_private_ip : null
}

output "traffic_generator_private_ip" {
  description = "Private IP of the traffic generator"
  value       = length(module.ml_data_generators) > 0 ? module.ml_data_generators[0].traffic_generator_private_ip : null
}

output "web_server_url" {
  description = "URL to access the ML web server"
  value       = length(module.ml_data_generators) > 0 ? "http://${module.ml_data_generators[0].web_server_public_ip}/" : null
}

output "api_endpoint" {
  description = "API endpoint for testing"
  value       = length(module.ml_data_generators) > 0 ? "http://${module.ml_data_generators[0].web_server_public_ip}:8080/api/users" : null
}

# ====================================
# COMPREHENSIVE MODE OUTPUTS (FULL MODE)
# ====================================

output "bastion_host_ip" {
  description = "Public IP of bastion host (full mode)"
  value       = var.deployment_mode == "full" && length(module.platform) > 0 ? module.platform[0].bastion_public_ip : null
}

output "bastion_connection_info" {
  description = "Information for connecting to the bastion host"
  value = var.deployment_mode == "full" && var.enable_bastion && length(module.platform) > 0 ? {
    instance_id = module.platform[0].bastion_instance_id
    public_ip   = module.platform[0].bastion_public_ip
    private_ip  = module.platform[0].bastion_private_ip
    ssh_command = module.platform[0].bastion_ssh_command
  } : null
}

output "nat_instance_info" {
  description = "NAT Instance information"
  value = var.enable_nat_instance ? {
    instance_id = var.deployment_mode == "full" ? (
      length(module.foundation) > 0 ? module.foundation[0].nat_instance_id : null
      ) : (
      length(module.ml_network) > 0 ? module.ml_network[0].nat_instance_id : null
    )
    private_ip = var.deployment_mode == "full" ? (
      length(module.foundation) > 0 ? module.foundation[0].nat_instance_private_ip : null
      ) : (
      length(module.ml_network) > 0 ? module.ml_network[0].nat_instance_private_ip : null
    )
    public_ip = var.deployment_mode == "full" ? (
      length(module.foundation) > 0 ? module.foundation[0].nat_public_ip : null
      ) : (
      length(module.ml_network) > 0 ? module.ml_network[0].nat_public_ip : null
    )
  } : null
}

output "web_tier_instances" {
  description = "Web tier instance information (full mode)"
  value = var.deployment_mode == "full" && length(module.web_tier) > 0 ? {
    instance_ids = module.web_tier[0].instance_ids
    public_ips   = module.web_tier[0].public_ips
    private_ips  = module.web_tier[0].private_ips
  } : null
}

output "app_tier_instances" {
  description = "Application tier instance information (full mode)"
  value = var.deployment_mode == "full" && length(module.app_tier) > 0 ? {
    instance_ids = module.app_tier[0].instance_ids
    private_ips  = module.app_tier[0].private_ips
  } : null
}

output "data_tier_instances" {
  description = "Data tier instance information (full mode)"
  value = var.deployment_mode == "full" && length(module.data_tier) > 0 ? {
    instance_ids = module.data_tier[0].instance_ids
    private_ips  = module.data_tier[0].private_ips
  } : null
}

# ====================================
# DATA COLLECTION INFORMATION
# ====================================

output "flow_logs_group" {
  description = "CloudWatch log group for VPC flow logs"
  value = var.deployment_mode == "full" ? (
    var.enable_flow_logs && length(module.foundation) > 0 ? module.foundation[0].flow_logs_group_name : null
    ) : (
    length(module.ml_data_generators) > 0 ? module.ml_data_generators[0].flow_logs_group_name : null
  )
}

output "ml_logs_group" {
  description = "CloudWatch log group for ML application logs"
  value       = length(module.ml_data_generators) > 0 ? module.ml_data_generators[0].ml_logs_group_name : null
}

# ====================================
# S3 STORAGE INFORMATION
# ====================================

output "s3_buckets" {
  description = "S3 buckets for ML data storage"
  value = length(module.ml_storage) > 0 ? {
    app_storage_bucket = module.ml_storage[0].app_storage_bucket_id
    logs_bucket        = module.ml_storage[0].logs_bucket_id
    bucket_arns = {
      app_storage = module.ml_storage[0].app_storage_bucket_arn
      logs        = module.ml_storage[0].logs_bucket_arn
    }
  } : null
}

output "data_export_info" {
  description = "Information about ML data export"
  value = {
    s3_export_enabled = var.enable_data_export
    export_bucket     = var.export_bucket_name
    storage_available = length(module.ml_storage) > 0 ? "enabled" : "disabled"
    retention_policy  = "30 days Standard → 90 days Glacier → Auto-delete"
  }
}

# ====================================
# ACCESS COMMANDS & MANAGEMENT
# ====================================

output "ssh_commands" {
  description = "SSH commands for accessing instances"
  value = {
    web_server = length(module.ml_data_generators) > 0 ? "ssh -i your-key.pem ec2-user@${module.ml_data_generators[0].web_server_public_ip}" : "Not available"

    bastion = var.deployment_mode == "full" && length(module.platform) > 0 ? "ssh -i your-key.pem ec2-user@${module.platform[0].bastion_public_ip}" : "Not available"

    traffic_generator = length(module.ml_data_generators) > 0 ? "Connect via bastion or NAT instance to ${module.ml_data_generators[0].traffic_generator_private_ip}" : "Not available"
  }
}

output "management_commands" {
  description = "Management commands for ML traffic generation"
  value = length(module.ml_data_generators) > 0 ? {
    traffic_status   = "sudo /opt/ml-traffic-gen/control.sh status"
    start_traffic    = "sudo /opt/ml-traffic-gen/control.sh start"
    stop_traffic     = "sudo /opt/ml-traffic-gen/control.sh stop"
    view_normal_logs = "tail -f /var/log/normal_traffic.log"
    view_attack_logs = "tail -f /var/log/attack_patterns.log"
    check_web_logs   = "tail -f /var/log/httpd/access_log"
  } : {}
}

# ====================================
# COST & PERFORMANCE INFORMATION
# ====================================

output "cost_summary" {
  description = "Estimated monthly costs by deployment mode"
  value = {
    deployment_mode = var.deployment_mode
    simplified_mode = "~$21/month (3x t3.micro + t3.nano NAT)"
    ml_focused_mode = "~$25/month (optimized for ML data generation)"
    full_mode       = "~$50-100/month (comprehensive learning infrastructure)"
    current_estimate = var.deployment_mode == "simplified" ? "~$21/month" : (
      var.deployment_mode == "ml-focused" ? "~$25/month" : "~$50-100/month"
    )
  }
}

# ====================================
# QUICK REFERENCE GUIDE
# ====================================

output "quick_reference" {
  description = "Quick reference for current deployment"
  value = {
    mode           = var.deployment_mode
    web_url        = length(module.ml_data_generators) > 0 ? "http://${module.ml_data_generators[0].web_server_public_ip}/" : "Not available"
    api_test       = length(module.ml_data_generators) > 0 ? "curl http://${module.ml_data_generators[0].web_server_public_ip}:8080/api/users" : "Not available"
    ssh_web_server = length(module.ml_data_generators) > 0 ? "ssh -i your-key.pem ec2-user@${module.ml_data_generators[0].web_server_public_ip}" : "Not available"
    bastion_access = var.deployment_mode == "full" && length(module.platform) > 0 ? "ssh -i your-key.pem ec2-user@${module.platform[0].bastion_public_ip}" : "Not available"
    change_mode    = "Set deployment_mode variable to 'simplified', 'ml-focused', or 'full'"
  }
}

output "deployment_summary" {
  description = "Complete deployment summary"
  value = {
    deployment_mode = var.deployment_mode
    environment     = var.environment
    vpc_cidr = var.deployment_mode == "full" ? (
      length(module.foundation) > 0 ? module.foundation[0].vpc_cidr_block : "Not deployed"
      ) : (
      length(module.ml_network) > 0 ? module.ml_network[0].vpc_cidr_block : "Not deployed"
    )

    active_services = {
      ml_data_generation = length(module.ml_data_generators) > 0 ? "active" : "disabled"
      web_server         = length(module.ml_data_generators) > 0 ? module.ml_data_generators[0].web_server_public_ip : "disabled"
      traffic_generator  = length(module.ml_data_generators) > 0 ? "active" : "disabled"
      bastion_host       = var.deployment_mode == "full" && var.enable_bastion ? "active" : "disabled"
      web_tier           = var.deployment_mode == "full" && var.enable_web_tier ? "active" : "disabled"
      app_tier           = var.deployment_mode == "full" && var.enable_app_tier ? "active" : "disabled"
      data_tier          = var.deployment_mode == "full" && var.enable_data_tier ? "active" : "disabled"
    }

    data_collection = {
      vpc_flow_logs   = var.enable_flow_logs ? "enabled" : "disabled"
      cloudwatch_logs = var.enable_cloudwatch_logs ? "enabled" : "disabled"
      log_retention   = "${var.log_retention_days} days"
    }

    cost_optimization = {
      nat_solution   = var.enable_nat_instance ? "NAT Instance (cost-effective)" : "No NAT"
      auto_shutdown  = var.auto_shutdown_enabled ? "enabled" : "disabled"
      instance_sizes = "Optimized for ${var.deployment_mode} mode"
    }
  }
} 