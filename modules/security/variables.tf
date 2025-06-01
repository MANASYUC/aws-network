variable "vpc_id" {
  description = "ID of the VPC"
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

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "app_server_subnet_cidr" {
  description = "CIDR block of the app server private subnet"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP CIDR (for SSH access)"
  type        = string
}