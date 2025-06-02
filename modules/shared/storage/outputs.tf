# ====================================
# SHARED STORAGE OUTPUTS
# ====================================

output "app_storage_bucket_id" {
  description = "ID of the application storage bucket"
  value       = aws_s3_bucket.app_storage.id
}

output "app_storage_bucket_arn" {
  description = "ARN of the application storage bucket"
  value       = aws_s3_bucket.app_storage.arn
}

output "logs_bucket_id" {
  description = "ID of the logs bucket"
  value       = var.enable_logging ? aws_s3_bucket.logs[0].id : null
}

output "logs_bucket_arn" {
  description = "ARN of the logs bucket"
  value       = var.enable_logging ? aws_s3_bucket.logs[0].arn : null
} 