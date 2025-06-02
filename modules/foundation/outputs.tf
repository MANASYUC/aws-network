# ====================================
# FOUNDATION MODULE - OUTPUTS
# ====================================
# These outputs expose the created network resources
# so they can be consumed by other modules
# ====================================

# VPC Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

# Internet Gateway
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# Public Subnet Information
output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_arns" {
  description = "List of ARNs of the public subnets"
  value       = aws_subnet.public[*].arn
}

# Private Subnet Information  
output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_arns" {
  description = "List of ARNs of the private subnets"
  value       = aws_subnet.private[*].arn
}

# NAT Gateway Information
output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_public_ips" {
  description = "List of public IP addresses of the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

# Route Table Information
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

# Availability Zone Information
output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}

# Network Summary for easy reference
output "network_summary" {
  description = "Summary of the network configuration"
  value = {
    vpc_id                = aws_vpc.main.id
    vpc_cidr             = aws_vpc.main.cidr_block
    environment          = var.environment
    public_subnets       = length(aws_subnet.public)
    private_subnets      = length(aws_subnet.private)
    availability_zones   = length(var.availability_zones)
    nat_gateways_enabled = var.enable_nat_gateway
    flow_logs_enabled    = var.enable_flow_logs
  }
} 