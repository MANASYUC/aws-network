variable "ami_id" {
  description = "AMI ID for the EC2 instance (Amazon Linux 2 recommended)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # Free Tier eligible
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the traffic client instance"
  type        = string
}

variable "target_url" {
  description = "Target URL for traffic generation (e.g., your app server URL)"
  type        = string
}
