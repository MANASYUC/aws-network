# ====================================
# SIMPLIFIED MODE VARIABLES
# ====================================
# Only variables needed for basic ML data generation

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
# LOGGING AND MONITORING
# ====================================

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = true
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
    Purpose     = "ML-Training-Data-Generation"
    CostCenter  = "Learning"
  }
} 