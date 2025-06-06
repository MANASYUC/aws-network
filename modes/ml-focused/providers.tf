# ====================================
# SIMPLIFIED ML INFRASTRUCTURE PROVIDERS
# ====================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

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
