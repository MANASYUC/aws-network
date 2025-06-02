variable "log_bucket_name" {
  description = "Name of the S3 bucket for logs"
  type        = string
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}

