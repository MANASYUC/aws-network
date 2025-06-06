# ====================================
# ML GENERATORS MODULE VARIABLES
# ====================================

# ====================================
# BASIC CONFIGURATION
# ====================================

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
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

# ====================================
# INSTANCE CONFIGURATION
# ====================================

variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "web_server_type" {
  description = "Instance type for web server"
  type        = string
  default     = "t3.micro"
}

variable "traffic_gen_type" {
  description = "Instance type for traffic generator"
  type        = string
  default     = "t3.micro"
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks for admin access"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 