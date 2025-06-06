# ====================================
# FULL ENTERPRISE AWS NETWORK ARCHITECTURE
# ====================================
# Complete 3-tier enterprise infrastructure for comprehensive learning
# Includes all AWS networking, security, and application tier components

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
  # Enterprise network configuration
  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Common tags
  common_tags = merge(var.common_tags, {
    Environment    = var.environment
    Project        = "AWS-Enterprise-Network-Architecture"
    Purpose        = "Complete-Infrastructure-Learning"
    DeploymentMode = "full"
    ManagedBy      = "Terraform"
    CreatedDate    = formatdate("YYYY-MM-DD", timestamp())
  })
}

# ====================================
# IAM ROLES AND POLICIES
# ====================================

module "iam" {
  source = "../../modules/iam"

  # Environment
  environment = var.environment

  # Feature toggles
  enable_admin_role   = true
  enable_bastion_role = var.enable_bastion
  enable_app_roles    = var.enable_app_tier

  # Tags
  common_tags = local.common_tags
}

# ====================================
# FOUNDATION LAYER
# ====================================

module "foundation" {
  source = "../../modules/foundation"

  # Environment
  environment = var.environment

  # Network Configuration
  vpc_cidr             = local.vpc_cidr
  availability_zones   = local.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  # Features
  enable_nat_instance = var.enable_nat_instance

  # NAT Configuration
  nat_instance_ami_id = data.aws_ami.amazon_linux.id
  nat_instance_type   = var.nat_instance_type
  key_name            = var.existing_key_name
  admin_cidr_blocks   = var.admin_cidr_blocks

  # Tags
  common_tags = local.common_tags

  depends_on = [module.iam]
}

# ====================================
# PLATFORM LAYER
# ====================================

module "platform" {
  source = "../../modules/platform"

  # Dependencies
  vpc_id             = module.foundation.vpc_id
  public_subnet_ids  = module.foundation.public_subnet_ids
  private_subnet_ids = module.foundation.private_subnet_ids

  # Environment
  environment = var.environment

  # Security Configuration
  admin_cidr_blocks = var.admin_cidr_blocks
  app_port          = var.app_port
  db_port           = var.db_port

  # Bastion Configuration
  enable_bastion        = var.enable_bastion
  bastion_ami_id        = data.aws_ami.amazon_linux.id
  bastion_instance_type = var.bastion_instance_type
  create_bastion_key    = false
  bastion_public_key    = ""
  existing_key_name     = var.existing_key_name

  # Monitoring
  enable_logging             = var.enable_logging
  enable_detailed_monitoring = var.enable_detailed_monitoring
  log_retention_days         = var.log_retention_days

  # Network Security
  enable_network_acls = var.enable_network_acls

  # Tags
  common_tags = local.common_tags

  depends_on = [module.foundation]
}

# ====================================
# APPLICATION TIERS
# ====================================

# Web Tier - Public facing web servers
module "web_tier" {
  count  = var.enable_web_tier ? 1 : 0
  source = "../../modules/applications/web-tier"

  # Dependencies
  vpc_id            = module.foundation.vpc_id
  subnet_ids        = module.foundation.public_subnet_ids
  security_group_id = module.platform.web_tier_security_group_id

  # Configuration
  environment    = var.environment
  instance_count = var.web_instance_count
  instance_type  = var.web_instance_type
  ami_id         = data.aws_ami.amazon_linux.id
  key_name       = var.existing_key_name

  # Tags
  common_tags = local.common_tags

  depends_on = [module.platform]
}

# App Tier - Application servers in private subnets
module "app_tier" {
  count  = var.enable_app_tier ? 1 : 0
  source = "../../modules/applications/app-tier"

  # Dependencies  
  vpc_id            = module.foundation.vpc_id
  subnet_ids        = module.foundation.private_subnet_ids
  security_group_id = module.platform.app_tier_security_group_id

  # Configuration
  environment    = var.environment
  instance_count = var.app_instance_count
  instance_type  = var.app_instance_type
  ami_id         = data.aws_ami.amazon_linux.id
  key_name       = var.existing_key_name
  app_port       = var.app_port

  # Tags
  common_tags = local.common_tags

  depends_on = [module.platform]
}

# Data Tier - Database servers in private subnets
module "data_tier" {
  count  = var.enable_data_tier ? 1 : 0
  source = "../../modules/applications/data-tier"

  # Dependencies
  vpc_id            = module.foundation.vpc_id
  subnet_ids        = module.foundation.private_subnet_ids
  security_group_id = module.platform.db_tier_security_group_id

  # Configuration
  environment   = var.environment
  instance_type = var.db_instance_type
  ami_id        = data.aws_ami.amazon_linux.id
  key_name      = var.existing_key_name
  db_port       = var.db_port

  # Tags
  common_tags = local.common_tags

  depends_on = [module.platform]
} 