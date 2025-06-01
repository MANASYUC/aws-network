variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# cidrs----
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

variable "my_ip_cidr" {
  description = "Your IP CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

# keys----
variable "ssh_key_name" {
  description = "Name of the SSH key pair for Bastion host"
  type        = string
}

# toggles----
variable "enable_bastion" {
  description = "Toggle to enable/disable bastion host"
  type        = bool
  default     = false
}

variable "enable_web_server" {
  description = "Set true to deploy web server"
  type        = bool
  default     = false
}

variable "enable_app_server" {
  description = "Toggle to enable/disable app server"
  type        = bool
  default     = false
}

variable "enable_db_server" {
  description = "Toggle to enable/disable db server"
  type        = bool
  default     = false
}

variable "enable_traffic" {
  description = "Toggle to enable/disable traffic client"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "Instance type for web server"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}
