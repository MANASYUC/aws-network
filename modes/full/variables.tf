# ====================================
<<<<<<< Updated upstream
# NEW IMPROVED VARIABLES CONFIGURATION
# ====================================
# Organized by layers and concerns for better maintainability
# ====================================

# ====================================
=======
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
>>>>>>> Stashed changes
# ENVIRONMENT & GLOBAL CONFIGURATION
# ====================================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
<<<<<<< Updated upstream
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
=======
  default     = "ml-dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod", "ml-dev", "ml-prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, ml-dev, ml-prod."
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
# LAYER 1: FOUNDATION (NETWORK)
# ====================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
=======
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
>>>>>>> Stashed changes
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "az_count" {
<<<<<<< Updated upstream
  description = "Number of availability zones to use"
=======
  description = "Number of availability zones to use (full mode only)"
>>>>>>> Stashed changes
  type        = number
  default     = 2
  
  validation {
    condition     = var.az_count >= 2 && var.az_count <= 4
    error_message = "AZ count must be between 2 and 4 for high availability."
  }
}

<<<<<<< Updated upstream
# Network CIDR blocks
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
=======
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (full mode)"
>>>>>>> Stashed changes
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
<<<<<<< Updated upstream
  description = "CIDR blocks for private subnets"
=======
  description = "CIDR blocks for private subnets (full mode)"
>>>>>>> Stashed changes
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

<<<<<<< Updated upstream
variable "enable_nat_instance" {
  description = "Enable NAT Instance for private subnet internet access (free tier friendly)"
=======
# ====================================
# NETWORKING & NAT CONFIGURATION
# ====================================

variable "enable_nat_instance" {
  description = "Enable NAT Instance for private subnet internet access"
>>>>>>> Stashed changes
  type        = bool
  default     = true
}

variable "nat_instance_type" {
  description = "Instance type for NAT instance"
  type        = string
<<<<<<< Updated upstream
  default     = "t2.micro"
  
  validation {
    condition     = contains(["t2.micro", "t2.small", "t3.micro", "t3.small"], var.nat_instance_type)
=======
  default     = "t3.nano"
  
  validation {
    condition     = contains(["t2.micro", "t2.small", "t3.nano", "t3.micro", "t3.small"], var.nat_instance_type)
>>>>>>> Stashed changes
    error_message = "NAT instance type should be small for cost efficiency."
  }
}

<<<<<<< Updated upstream
variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
=======
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
>>>>>>> Stashed changes
  type        = bool
  default     = false
}

<<<<<<< Updated upstream
# ====================================
# LAYER 2: PLATFORM (SECURITY & MANAGEMENT)
# ====================================

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for administrative access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "Port for application tier communication"
  type        = number
  default     = 8080
}

=======
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

>>>>>>> Stashed changes
variable "db_port" {
  description = "Port for database tier communication"
  type        = number
  default     = 3306
}

<<<<<<< Updated upstream
# Bastion Configuration
variable "enable_bastion" {
  description = "Enable bastion host deployment"
  type        = bool
  default     = true
=======
# Bastion Configuration (Full Mode)
variable "enable_bastion" {
  description = "Enable bastion host deployment"
  type        = bool
  default     = false
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
  description = "Public key content for bastion SSH access (required if create_bastion_key is true)"
=======
  description = "Public key content for bastion SSH access"
>>>>>>> Stashed changes
  type        = string
  default     = ""
}

<<<<<<< Updated upstream
variable "existing_key_name" {
  description = "Name of existing SSH key pair to use"
  type        = string
  default     = ""
}

# Monitoring & Logging
=======
# Monitoring & Logging (Full Mode)
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

=======
>>>>>>> Stashed changes
variable "enable_network_acls" {
  description = "Enable custom Network ACLs"
  type        = bool
  default     = false
}

# ====================================
<<<<<<< Updated upstream
# LAYER 3: APPLICATIONS
=======
# APPLICATION TIERS (FULL MODE ONLY)
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
=======
variable "db_instance_count" {
  description = "Number of database tier instances"
  type        = number
  default     = 2
}

>>>>>>> Stashed changes
variable "db_instance_type" {
  description = "Instance type for database tier"
  type        = string
  default     = "t2.micro"
}

<<<<<<< Updated upstream
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
=======
# ====================================
# ML SERVICES (OPTIONAL FOR BOTH MODES)
# ====================================

variable "enable_ml_services" {
  description = "Enable ML services module"
>>>>>>> Stashed changes
  type        = bool
  default     = false
}

<<<<<<< Updated upstream
variable "s3_bucket_prefix" {
  description = "Prefix for S3 bucket names"
  type        = string
  default     = "aws-network"
}

variable "enable_s3_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = false
}

variable "s3_retention_days" {
  description = "S3 object retention period in days"
  type        = number
  default     = 90
}
=======
variable "enable_ml_pipeline" {
  description = "Enable ML pipeline processing"
  type        = bool
  default     = false
}

variable "enable_data_processing" {
  description = "Enable data processing services"
  type        = bool
  default     = false
}

variable "ml_instance_type" {
  description = "Instance type for ML services"
  type        = string
  default     = "t3.medium"
} 
>>>>>>> Stashed changes
