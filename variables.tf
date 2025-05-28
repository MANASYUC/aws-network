variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "enable_bastion" {
  description = "Toggle to enable/disable bastion host"
  type        = bool
  default     = false
}

variable "bastion_ami" {
  description = "AMI ID for Bastion Host"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 (us-east-1 example)
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair for Bastion host"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your IP CIDR block for SSH access "
  type        = string
  default     = "0.0.0.0/0"  
}