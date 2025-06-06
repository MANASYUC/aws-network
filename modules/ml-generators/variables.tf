# ====================================
# ML GENERATORS MODULE - VARIABLES
# ====================================

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
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

variable "ami_id" {
  description = "AMI ID for EC2 instances"
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

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for admin access"
  type        = list(string)
}

variable "enable_cloudwatch" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
} 