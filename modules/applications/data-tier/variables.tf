# ====================================
# DATA TIER VARIABLES
# ====================================

variable "vpc_id" {
  description = "VPC ID where data tier will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for data tier deployment"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for data tier instances"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "Instance type for data tier"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for data tier instances"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name for instances"
  type        = string
}

variable "db_port" {
  description = "Port for database communication"
  type        = number
  default     = 3306
}

variable "enable_encryption" {
  description = "Enable encryption for database storage"
  type        = bool
  default     = true
}

variable "backup_retention" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 