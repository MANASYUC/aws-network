variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "nat_instance_ami" {
  type        = string
  description = "AMI ID for the NAT Instance"
}
