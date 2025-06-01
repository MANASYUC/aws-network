variable "vpc_id" {}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "app_server_subnet_cidr" {
  description = "CIDR block of the app server private subnet"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP CIDR (for SSH access)"
  type        = string
}