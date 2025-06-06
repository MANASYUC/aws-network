# ====================================
# MERGED VARIABLES CONFIGURATION
# ====================================
# Supports both simplified ML-focused and comprehensive learning modes
# ====================================

# ====================================
# DEPLOYMENT MODE SELECTION
# ====================================

variable "deployment_mode" {
  description = "Deployment mode: 'simplified' (minimal cost), 'ml-focused' (ML optimized), or 'full' (comprehensive learning)"
  type        = string
  default     = "simplified"

  validation {
    condition     = contains(["simplified", "ml-focused", "full"], var.deployment_mode)
    error_message = "Deployment mode must be one of: simplified, ml-focused, full."
  }
}

# ====================================
# ENVIRONMENT & GLOBAL CONFIGURATION
# ====================================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "ml-dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "ml-dev", "ml-prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, ml-dev, ml-prod."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project   = "AWS-Network-Architecture"
    Owner     = "DevOps-Team"
    ManagedBy = "Terraform"
  }
}

# ====================================
# REQUIRED VARIABLES (ALL MODES)
# ====================================

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for admin access"
  type        = list(string)
  validation {
    condition = length(var.admin_cidr_blocks) > 0 && alltrue([
      for cidr in var.admin_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "At least one valid CIDR block must be provided."
  }
}

variable "existing_key_name" {
  description = "Name of existing EC2 key pair for SSH access"
  type        = string
  validation {
    condition     = length(var.existing_key_name) > 0
    error_message = "Key name cannot be empty."
  }
}

# ====================================
# NETWORK CONFIGURATION (FULL MODE)
# ====================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC (used in full mode)"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "az_count" {
  description = "Number of availability zones to use (full mode only)"
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 4
    error_message = "AZ count must be between 2 and 4 for high availability."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (full mode)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (full mode)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

# ====================================
# NETWORKING & NAT CONFIGURATION
# ====================================

variable "enable_nat_instance" {
  description = "Enable NAT Instance for private subnet internet access"
  type        = bool
  default     = true
}

variable "nat_instance_type" {
  description = "Instance type for NAT instance"
  type        = string
  default     = "t3.nano"

  validation {
    condition     = contains(["t2.micro", "t2.small", "t3.nano", "t3.micro", "t3.small"], var.nat_instance_type)
    error_message = "NAT instance type should be small for cost efficiency."
  }
}

# ====================================
# ML-FOCUSED VARIABLES
# ====================================

variable "app_port" {
  description = "Custom application port for testing"
  type        = number
  default     = 8080
}

variable "web_server_type" {
  description = "Instance type for web server (ML target)"
  type        = string
  default     = "t3.micro"
}

variable "traffic_gen_type" {
  description = "Instance type for traffic generator"
  type        = string
  default     = "t3.micro"
}

# Data Collection Options
variable "enable_flow_logs" {
  description = "Enable VPC flow logs for network traffic analysis"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs for application monitoring"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 7
  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 365
    error_message = "Log retention must be between 1 and 365 days."
  }
}

# Traffic Generation Configuration
variable "enable_traffic_patterns" {
  description = "Enable automated traffic pattern generation"
  type        = bool
  default     = true
}

variable "traffic_intensity" {
  description = "Traffic generation intensity (low, medium, high)"
  type        = string
  default     = "medium"
  validation {
    condition     = contains(["low", "medium", "high"], var.traffic_intensity)
    error_message = "Traffic intensity must be low, medium, or high."
  }
}

# ML Data Export Options
variable "enable_data_export" {
  description = "Enable automatic export of ML training data to S3"
  type        = bool
  default     = false
}

variable "export_bucket_name" {
  description = "S3 bucket name for ML data export (optional)"
  type        = string
  default     = ""
}

# ====================================
# COST OPTIMIZATION VARIABLES
# ====================================

variable "auto_shutdown_enabled" {
  description = "Enable automatic shutdown during off-hours to save costs"
  type        = bool
  default     = true
}

variable "shutdown_schedule" {
  description = "Cron expression for shutdown schedule (default: 10 PM EST weekdays)"
  type        = string
  default     = "0 22 * * 1-5"
}

variable "startup_schedule" {
  description = "Cron expression for startup schedule (default: 8 AM EST weekdays)"
  type        = string
  default     = "0 8 * * 1-5"
}

# ====================================
# FULL MODE VARIABLES (COMPREHENSIVE LEARNING)
# ====================================

variable "db_port" {
  description = "Port for database tier communication"
  type        = number
  default     = 3306
}

# Bastion Configuration (Full Mode)
variable "enable_bastion" {
  description = "Enable bastion host deployment"
  type        = bool
  default     = false
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t2.micro"
}

variable "create_bastion_key" {
  description = "Create new SSH key pair for bastion"
  type        = bool
  default     = false
}

variable "bastion_public_key" {
  description = "Public key content for bastion SSH access"
  type        = string
  default     = ""
}

# Monitoring & Logging (Full Mode)
variable "enable_logging" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = true
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

variable "enable_network_acls" {
  description = "Enable custom Network ACLs"
  type        = bool
  default     = false
}

# ====================================
# APPLICATION TIERS (FULL MODE ONLY)
# ====================================

# Web Tier
variable "enable_web_tier" {
  description = "Enable web tier deployment"
  type        = bool
  default     = false
}

variable "web_instance_count" {
  description = "Number of web tier instances"
  type        = number
  default     = 2
}

variable "web_instance_type" {
  description = "Instance type for web tier"
  type        = string
  default     = "t2.micro"
}

# Application Tier
variable "enable_app_tier" {
  description = "Enable application tier deployment"
  type        = bool
  default     = false
}

variable "app_instance_count" {
  description = "Number of application tier instances"
  type        = number
  default     = 2
}

variable "app_instance_type" {
  description = "Instance type for application tier"
  type        = string
  default     = "t2.micro"
}

# Data Tier
variable "enable_data_tier" {
  description = "Enable data tier deployment"
  type        = bool
  default     = false
}

variable "db_instance_count" {
  description = "Number of database tier instances"
  type        = number
  default     = 2
}

variable "db_instance_type" {
  description = "Instance type for database tier"
  type        = string
  default     = "t2.micro"
}

variable "enable_db_encryption" {
  description = "Enable database encryption"
  type        = bool
  default     = true
}

variable "db_backup_retention" {
  description = "Database backup retention period in days"
  type        = number
  default     = 7

  validation {
    condition     = var.db_backup_retention >= 1 && var.db_backup_retention <= 35
    error_message = "Backup retention must be between 1 and 35 days."
  }
}

# ====================================
# SHARED SERVICES
# ====================================

variable "enable_shared_storage" {
  description = "Enable shared S3 storage resources"
  type        = bool
  default     = false
}

variable "s3_bucket_prefix" {
  description = "Prefix for S3 bucket names"
  type        = string
  default     = "aws-network"
}

variable "enable_s3_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = true
}

variable "s3_retention_days" {
  description = "Number of days to retain S3 objects"
  type        = number
  default     = 30
}

# ====================================
# ML SERVICES (OPTIONAL FOR BOTH MODES)
# ====================================

variable "enable_ml_services" {
  description = "Enable ML services module"
  type        = bool
  default     = false
}

variable "ml_bucket_prefix" {
  description = "Prefix for ML-specific S3 buckets"
  type        = string
  default     = "ml-data"
}

variable "enable_enhanced_monitoring" {
  description = "Enable enhanced monitoring for ML workloads"
  type        = bool
  default     = false
}

variable "export_schedule" {
  description = "Cron expression for automated data export"
  type        = string
  default     = "0 2 * * *" # Daily at 2 AM
}
