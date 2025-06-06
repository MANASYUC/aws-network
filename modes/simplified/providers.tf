# ====================================
# SIMPLIFIED ML INFRASTRUCTURE PROVIDERS
# ====================================

provider "aws" {
  region = "us-east-1" # Change this to your preferred region

  default_tags {
    tags = {
      Project   = "ML-Network-Data-Generator"
      ManagedBy = "Terraform"
      Purpose   = "ML-Training-Data"
    }
  }
} 