variable "ami_id" {
  type        = string
  description = "AMI ID to use for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type (e.g., t2.micro, t3.medium)"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet to launch the instance in"
}

variable "security_group_id" {
  type        = string
  description = "The security group ID to associate with the instance"
}

variable "key_name" {
  type        = string
  description = "The name of the SSH key pair to use for the instance"
}
