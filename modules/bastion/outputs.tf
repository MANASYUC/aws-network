output "bastion_public_ip" {
  value = var.enable_bastion ? aws_instance.bastion[0].public_ip : null

}

output "bastion_sg_id" {
    value = var.enable_bastion ? aws_security_group.bastion_sg.id : null
}