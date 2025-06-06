# ====================================
# AWS NETWORK INFRASTRUCTURE - ROOT VARIABLES
# ====================================
# Variables for the main Terraform configuration
# ====================================

# ====================================
# ENVIRONMENT & GLOBAL CONFIGURATION
# ====================================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
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
# REQUIRED SECURITY CONFIGURATION
# ====================================

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for administrative access"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # WARNING: Change this to your specific IP range
  
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
  default     = ""
  
  validation {
    condition     = length(var.existing_key_name) > 0
    error_message = "Key name cannot be empty - you must provide an existing EC2 key pair name."
  }
}

# ====================================
# NETWORK CONFIGURATION
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

# ====================================
# NAT CONFIGURATION
# ====================================

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
    condition     = contains(["t2.micro", "t2.small", "t3.nano", "t3.micro", "t3.small"], var.nat_instance_type)
    error_message = "NAT instance type should be small for cost efficiency."
  }
}

# ====================================
# MONITORING & LOGGING
# ====================================

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

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
  
  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 365
    error_message = "Log retention must be between 1 and 365 days."
  }
}

variable "enable_network_acls" {
  description = "Enable custom Network ACLs"
  type        = bool
  default     = false
}

# ====================================
# APPLICATION PORTS
# ====================================

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

# ====================================
# BASTION CONFIGURATION
# ====================================

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

# ====================================
# APPLICATION TIERS (OPTIONAL)
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
  default     = true
}

variable "s3_retention_days" {
  description = "Number of days to retain S3 objects"
  type        = number
  default     = 30
} 