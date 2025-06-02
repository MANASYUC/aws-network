# ====================================
# DATA TIER OUTPUTS
# ====================================

output "instance_id" {
  description = "Database instance ID"
  value       = aws_instance.db.id
}

output "instance_private_ip" {
  description = "Database instance private IP"
  value       = aws_instance.db.private_ip
}

output "storage_volume_id" {
  description = "Database storage volume ID"
  value       = aws_ebs_volume.db_storage.id
} 