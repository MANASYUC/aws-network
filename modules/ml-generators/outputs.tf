# ====================================
# ML GENERATORS MODULE - OUTPUTS
# ====================================

output "web_server_instance_id" {
  description = "Instance ID of the web server"
  value       = aws_instance.web_server.id
}

output "web_server_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web_server.public_ip
}

output "web_server_private_ip" {
  description = "Private IP of the web server"
  value       = aws_instance.web_server.private_ip
}

output "traffic_generator_instance_id" {
  description = "Instance ID of the traffic generator"
  value       = aws_instance.traffic_generator.id
}

output "traffic_generator_private_ip" {
  description = "Private IP of the traffic generator"
  value       = aws_instance.traffic_generator.private_ip
}

output "web_server_security_group_id" {
  description = "Security group ID for web server"
  value       = aws_security_group.web_server.id
}

output "traffic_generator_security_group_id" {
  description = "Security group ID for traffic generator"
  value       = aws_security_group.traffic_generator.id
}

output "flow_logs_group_name" {
  description = "CloudWatch log group name for VPC flow logs"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.flow_logs[0].name : null
}

output "ml_logs_group_name" {
  description = "CloudWatch log group name for ML application logs"
  value       = var.enable_cloudwatch ? aws_cloudwatch_log_group.ml_logs[0].name : null
} 