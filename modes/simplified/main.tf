# ====================================
# SIMPLIFIED AWS NETWORK FOR ML TRAINING
# ====================================
# Lightweight infrastructure optimized for Free Tier learning
# Focused on ML data generation with minimal complexity

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ====================================
# DATA SOURCES
# ====================================

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ====================================
# LOCAL CONFIGURATION
# ====================================

locals {
  # Simplified network configuration
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

  # Common tags
  common_tags = merge(var.common_tags, {
    Environment    = var.environment
    Project        = "ML-Network-Data-Generator"
    Purpose        = "ML-Training-Data"
    DeploymentMode = "simplified"
    ManagedBy      = "Terraform"
    CreatedDate    = formatdate("YYYY-MM-DD", timestamp())
  })
}

# ====================================
# SIMPLIFIED ML NETWORK
# ====================================

module "ml_network" {
  source = "../../modules/ml-network"

  # Basic configuration
  environment          = var.environment
  vpc_cidr             = local.vpc_cidr
  availability_zones   = local.availability_zones
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs

  # Simplified features
  enable_nat_instance = true
  nat_instance_type   = var.nat_instance_type

  # Access configuration
  admin_cidr_blocks = var.admin_cidr_blocks
  key_name          = var.existing_key_name

  tags = local.common_tags
}

# ====================================
# ML DATA GENERATORS
# ====================================

module "ml_data_generators" {
  source = "../../modules/ml-generators"

  # Network dependencies
  vpc_id             = module.ml_network.vpc_id
  public_subnet_ids  = module.ml_network.public_subnet_ids
  private_subnet_ids = module.ml_network.private_subnet_ids

  # Instance configuration
  web_server_type  = var.web_server_type
  traffic_gen_type = var.traffic_gen_type

  # Basic configuration
  environment       = var.environment
  ami_id            = data.aws_ami.amazon_linux.id
  key_name          = var.existing_key_name
  admin_cidr_blocks = var.admin_cidr_blocks

  # Data collection settings
  enable_flow_logs   = var.enable_flow_logs
  enable_cloudwatch  = var.enable_cloudwatch_logs
  log_retention_days = 1 # Free tier optimization

  tags = local.common_tags

  depends_on = [module.ml_network]
}

# ====================================
# SIMPLIFIED SECURITY
# ====================================

module "ml_security" {
  source = "../../modules/ml-security"

  # Environment
  environment = var.environment

  # Network context
  vpc_id = module.ml_network.vpc_id

  # Access configuration
  admin_cidr_blocks = var.admin_cidr_blocks

  # Basic ports
  web_port    = 80
  ssh_port    = 22
  custom_port = var.app_port

  tags = local.common_tags

  depends_on = [module.ml_network]
}

# ====================================
# S3 STORAGE FOR ML DATA
# ====================================

module "ml_storage" {
  source = "../../modules/shared"

  # Environment
  environment = var.environment

  # S3 Configuration
  bucket_prefix  = "ml-network-data"
  enable_logging = true
  retention_days = 30 # Conservative retention for free tier

  # Tags
  common_tags = local.common_tags
} 