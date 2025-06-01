output "app_instance_id" {
  value = length(aws_instance.app) > 0 ?  aws_instance.app.id : null
}
