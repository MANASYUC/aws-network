output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

# Using NAT instance ID instead of NAT gateway
output "nat_gateway_ids" {
  value = [aws_instance.nat_instance.id]
}

output "eip_ids" {
  value = aws_eip.nat[*].id
}

output "nat_instance_eni_id" {
  value = aws_instance.nat_instance.primary_network_interface_id
}
