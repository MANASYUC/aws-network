output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.nat_gw[*].id
}

output "eip_ids" {
  value = aws_eip.nat[*].id
}
