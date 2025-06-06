# ====================================
# ML GENERATORS MODULE OUTPUTS
# ====================================

# Instance Information
output "web_server_id" {
  description = "ID of the web server instance"
  value       = aws_instance.web_server.id
}

output "web_server_private_ip" {
  description = "Private IP of the web server"
  value       = aws_instance.web_server.private_ip
}

output "web_server_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web_server.public_ip
}

output "traffic_generator_id" {
  description = "ID of the traffic generator instance"
  value       = aws_instance.traffic_generator.id
}

output "traffic_generator_private_ip" {
  description = "Private IP of the traffic generator"
  value       = aws_instance.traffic_generator.private_ip
}

# Security Group Information
output "web_server_security_group_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.web_server.id
}

output "traffic_generator_security_group_id" {
  description = "ID of the traffic generator security group"
  value       = aws_security_group.traffic_generator.id
} 