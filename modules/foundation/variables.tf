# ====================================
# FOUNDATION MODULE VARIABLES
# ====================================

# ====================================
# BASIC CONFIGURATION
# ====================================

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

# ====================================
# NAT CONFIGURATION
# ====================================

variable "enable_nat_instance" {
  description = "Enable NAT instance for private subnet internet access"
  type        = bool
  default     = true
}

variable "nat_instance_ami_id" {
  description = "AMI ID for NAT instance"
  type        = string
}

variable "nat_instance_type" {
  description = "Instance type for NAT instance"
  type        = string
  default     = "t3.nano"
}

variable "key_name" {
  description = "EC2 Key Pair name for NAT instance"
  type        = string
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for admin access"
  type        = list(string)
}

# ====================================
# TAGGING
# ====================================

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 