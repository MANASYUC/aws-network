# ====================================
# WEB TIER OUTPUTS
# ====================================

output "instance_ids" {
  description = "List of web tier instance IDs"
  value       = aws_instance.web[*].id
}

output "instance_private_ips" {
  description = "List of web tier instance private IPs"
  value       = aws_instance.web[*].private_ip
}

output "instance_public_ips" {
  description = "List of web tier instance public IPs"
  value       = aws_instance.web[*].public_ip
} 