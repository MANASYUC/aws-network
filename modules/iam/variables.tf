# ====================================
# IAM MODULE VARIABLES
# ====================================

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs IAM role"
  type        = bool
  default     = false
}

variable "enable_admin_role" {
  description = "Enable administrative role"
  type        = bool
  default     = true
}

variable "enable_bastion_role" {
  description = "Enable bastion host role"
  type        = bool
  default     = false
}

variable "enable_app_roles" {
  description = "Enable application tier roles"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ====================================
# FUTURE VARIABLES
# ====================================
# Additional variables can be added here for:
# - ECS task role configurations
# - S3 bucket access configurations
# - RDS access configurations
# etc. 