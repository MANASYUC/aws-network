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

output "load_balancer_arn" {
  description = "ARN of the web tier load balancer"
  value       = var.enable_load_balancer ? aws_lb.web[0].arn : null
}

output "load_balancer_dns_name" {
  description = "DNS name of the web tier load balancer"
  value       = var.enable_load_balancer ? aws_lb.web[0].dns_name : null
}

output "load_balancer_zone_id" {
  description = "Zone ID of the web tier load balancer"
  value       = var.enable_load_balancer ? aws_lb.web[0].zone_id : null
}

output "target_group_arn" {
  description = "ARN of the web tier target group"
  value       = var.enable_load_balancer ? aws_lb_target_group.web[0].arn : null
} 