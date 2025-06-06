# ====================================
# ML-FOCUSED MODE VARIABLES
# ====================================
# Enhanced variables for comprehensive ML training data generation

# ====================================
# BASIC CONFIGURATION
# ====================================

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "ml-dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# ====================================
# INSTANCE CONFIGURATION
# ====================================

variable "existing_key_name" {
  description = "Name of existing EC2 key pair for SSH access"
  type        = string
}

variable "web_server_type" {
  description = "EC2 instance type for web server"
  type        = string
  default     = "t3.micro"
}

variable "traffic_gen_type" {
  description = "EC2 instance type for traffic generator"
  type        = string
  default     = "t3.micro"
}

variable "nat_instance_type" {
  description = "EC2 instance type for NAT instance"
  type        = string
  default     = "t3.nano"
}

variable "bastion_instance_type" {
  description = "EC2 instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

# ====================================
# SECURITY CONFIGURATION
# ====================================

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for admin access (your IP)"
  type        = list(string)
  validation {
    condition = alltrue([
      for cidr in var.admin_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All admin_cidr_blocks must be valid CIDR notation."
  }
}

variable "app_port" {
  description = "Custom application port"
  type        = number
  default     = 8080
}

# ====================================
# ML-SPECIFIC CONFIGURATION
# ====================================

variable "ml_bucket_prefix" {
  description = "Prefix for ML data S3 buckets"
  type        = string
  default     = "ml-network-anomaly-data"
}

variable "traffic_intensity" {
  description = "Traffic generation intensity for ML training"
  type        = string
  default     = "medium"
  validation {
    condition     = contains(["low", "medium", "high"], var.traffic_intensity)
    error_message = "Traffic intensity must be one of: low, medium, high."
  }
}

variable "enable_data_export" {
  description = "Enable automated ML data export to S3"
  type        = bool
  default     = true
}

variable "export_schedule" {
  description = "Cron schedule for data export (default: every hour)"
  type        = string
  default     = "0 * * * *"
}

# ====================================
# LOGGING AND MONITORING
# ====================================

variable "s3_retention_days" {
  description = "S3 data retention days for ML datasets"
  type        = number
  default     = 90
}

# ====================================
# OPTIONAL FEATURES
# ====================================

variable "enable_bastion" {
  description = "Enable bastion host for secure access"
  type        = bool
  default     = false
}

variable "enable_enhanced_monitoring" {
  description = "Enable enhanced CloudWatch monitoring"
  type        = bool
  default     = false
}

# ====================================
# TAGGING
# ====================================

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "AWS-Network-Learning"
    Environment = "Development"
    Owner       = "ML-Learning"
    Purpose     = "Anomaly-Detection-Training"
    CostCenter  = "Learning"
    DataTypes   = "Network,Auth,System,App,TimeSeries"
  }
} 