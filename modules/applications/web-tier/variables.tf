# ====================================
# WEB TIER VARIABLES
# ====================================

variable "vpc_id" {
  description = "VPC ID where web tier will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for web tier deployment"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for web tier instances"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_count" {
  description = "Number of web tier instances"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Instance type for web tier"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "AMI ID for web tier instances"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name for instances"
  type        = string
}

variable "enable_load_balancer" {
  description = "Enable load balancer for web tier"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 