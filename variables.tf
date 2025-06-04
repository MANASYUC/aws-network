# ====================================
# NEW IMPROVED VARIABLES CONFIGURATION
# ====================================
# Organized by layers and concerns for better maintainability
# ====================================

# ====================================
# ENVIRONMENT & GLOBAL CONFIGURATION
# ====================================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
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
# LAYER 1: FOUNDATION (NETWORK)
# ====================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
  
  validation {
    condition     = var.az_count >= 2 && var.az_count <= 4
    error_message = "AZ count must be between 2 and 4 for high availability."
  }
}

# Network CIDR blocks
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "enable_nat_instance" {
  description = "Enable NAT Instance for private subnet internet access (free tier friendly)"
  type        = bool
  default     = true
}

variable "nat_instance_type" {
  description = "Instance type for NAT instance"
  type        = string
  default     = "t2.micro"
  
  validation {
    condition     = contains(["t2.micro", "t2.small", "t3.micro", "t3.small"], var.nat_instance_type)
    error_message = "NAT instance type should be small for cost efficiency."
  }
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

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

variable "db_port" {
  description = "Port for database tier communication"
  type        = number
  default     = 3306
}

# Bastion Configuration
variable "enable_bastion" {
  description = "Enable bastion host deployment"
  type        = bool
  default     = true
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
  description = "Public key content for bastion SSH access (required if create_bastion_key is true)"
  type        = string
  default     = ""
}

variable "existing_key_name" {
  description = "Name of existing SSH key pair to use"
  type        = string
  default     = ""
}

# Monitoring & Logging
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

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "enable_network_acls" {
  description = "Enable custom Network ACLs"
  type        = bool
  default     = false
}

# ====================================
# LAYER 3: APPLICATIONS
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
  default     = false
}

variable "s3_retention_days" {
  description = "S3 object retention period in days"
  type        = number
  default     = 90
}