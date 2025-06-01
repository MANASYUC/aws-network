variable "bastion_ami" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

variable "my_ip_cidr" {
  type = string
}

variable "enable_bastion" {
  type = bool
  default = false
}

variable "bastion_sg_id" {
  description = "Security group ID for the bastion host"
  type        = string
}