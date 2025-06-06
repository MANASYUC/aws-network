# ====================================
# PLATFORM MODULE - INPUT VARIABLES
# ====================================

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

# Network inputs from core layer
variable "vpc_id" {
  description = "ID of the VPC where platform resources will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

# Security configuration
variable "admin_cidr_blocks" {
  description = "List of CIDR blocks allowed for admin access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "Port number for application tier"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Port number for database tier"
  type        = number
  default     = 3306
}

# Bastion configuration
variable "enable_bastion" {
  description = "Enable bastion host deployment"
  type        = bool
  default     = true
}

variable "bastion_ami_id" {
  description = "AMI ID for bastion host"
  type        = string
  default     = ""
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_root_volume_size" {
  description = "Root volume size for bastion host in GB"
  type        = number
  default     = 20
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

variable "existing_key_name" {
  description = "Name of existing SSH key pair to use"
  type        = string
  default     = ""
}

# Logging and monitoring
variable "enable_logging" {
  description = "Enable logging"
  type        = bool
  default     = true
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 7
}

# Network security
variable "enable_network_acls" {
  description = "Enable custom Network ACLs"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 
