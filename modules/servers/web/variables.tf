variable "vpc_id" {}

variable "enable_web_server" {
  description = "Toggle to enable or disable web server"
  type        = bool
  default     = false
}

variable "ami_id" {
  description = "AMI ID to launch"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet to launch instance in"
  type        = string
}


variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = null
}

variable "bastion_sg_id" {
  description = "Security group ID of bastion host"
  type        = string
}

variable "web_sg_id" {
  description = "Security group ID for the web server"
  type        = string
}