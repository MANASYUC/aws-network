# ====================================
# APPLICATION TIER VARIABLES
# ====================================

variable "vpc_id" {
  description = "VPC ID where app tier will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for app tier deployment"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for app tier instances"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_count" {
  description = "Number of app tier instances"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Instance type for app tier"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for app tier instances"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name for instances"
  type        = string
}

variable "app_port" {
  description = "Port for application communication"
  type        = number
  default     = 8080
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 