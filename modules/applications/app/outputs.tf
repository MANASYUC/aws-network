# ====================================
# APPLICATION TIER OUTPUTS
# ====================================

output "instance_ids" {
  description = "List of app tier instance IDs"
  value       = aws_instance.app[*].id
}

output "instance_private_ips" {
  description = "List of app tier instance private IPs"
  value       = aws_instance.app[*].private_ip
} 