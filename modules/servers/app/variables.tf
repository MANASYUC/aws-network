variable "ami_id" {
  type        = string
  description = "The Amazon Machine Image (AMI) ID to use for launching the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "The type of EC2 instance to launch (e.g., t2.micro, t3.medium)"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where the EC2 instance will be deployed"
}

variable "security_group_id" {
  type        = string
  description = "The security group ID to associate with the EC2 instance"
}

variable "key_name" {
  type        = string
  description = "The name of the existing EC2 Key Pair to enable SSH access"
}
