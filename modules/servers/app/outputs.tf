output "app_instance_id" {
  description = "ID of the app server EC2 instance"
  value       = length(aws_instance.app) > 0 ? aws_instance.app.id : null
}

output "subnet_id" {
  description = "Subnet ID where the app server is deployed"
  value       = var.subnet_id
}
