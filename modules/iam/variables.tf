# ====================================
# IAM MODULE - INPUT VARIABLES
# ====================================

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs IAM resources"
  type        = bool
  default     = false
}

variable "enable_admin_role" {
  description = "Enable admin role with EC2 and S3 access"
  type        = bool
  default     = false
}

variable "enable_bastion_role" {
  description = "Enable bastion host IAM role"
  type        = bool
  default     = false
}

variable "enable_app_roles" {
  description = "Enable application tier IAM roles"
  type        = bool
  default     = false
}

variable "enable_lambda_roles" {
  description = "Enable Lambda execution roles"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all IAM resources"
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