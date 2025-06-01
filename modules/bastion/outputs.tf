output "bastion_public_ip" {
  value = length(aws_instance.bastion) > 0 ? aws_instance.bastion[0].public_ip : null

}

output "bastion_sg_id" {
    value = length(aws_instance.bastion) > 0 ? aws_security_group.bastion_sg.id : null
}