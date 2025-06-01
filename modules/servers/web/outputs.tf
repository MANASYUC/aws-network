output "instance_id" {
  value       = length(aws_instance.web) > 0 ? aws_instance.web[0].id : null
  description = "The ID of the web server instance"
}

output "public_ip" {
  value       = length(aws_instance.web) > 0 ? aws_instance.web[0].public_ip : null
  description = "The public IP of the web server"
}
