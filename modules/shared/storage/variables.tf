# ====================================
# SHARED STORAGE VARIABLES
# ====================================

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket names"
  type        = string
  default     = "aws-network-arch"
}

variable "enable_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = true
}

variable "retention_days" {
  description = "S3 object retention period in days"
  type        = number
  default     = 90
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 