output "instance_id" {
  value       = aws_instance.web[0].id
  description = "The ID of the web server instance"
}

output "public_ip" {
  value       = aws_instance.web[0].public_ip
  description = "The public IP of the web server"
}
