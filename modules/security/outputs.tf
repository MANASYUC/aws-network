output "security_group_id" {
  description = "ID of the main security group"
  value       = aws_security_group.security_g.id
}

output "app_sg_id" {
  description = "ID of the application server security group"
  value       = aws_security_group.app_sg.id
}

output "db_sg_id" {
  description = "ID of the database server security group"
  value       = aws_security_group.db_sg.id
}

output "traffic_client_sg" {
  description = "ID of the traffic client security group"
  value       = aws_security_group.traffic_client_sg.id
}
