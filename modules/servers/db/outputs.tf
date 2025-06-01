output "db_instance_id" {
  value = length(aws_instance.db) > 0 ? aws_instance.db.id : null
}
