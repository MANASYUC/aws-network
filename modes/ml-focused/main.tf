# ====================================
# ML-FOCUSED AWS NETWORK FOR ANOMALY DETECTION
# ====================================
# Enhanced infrastructure for comprehensive ML training data generation
# Optimized for anomaly detection with advanced data collection

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
  # ML-focused network configuration
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

  # Common tags
  common_tags = merge(var.common_tags, {
    Environment    = var.environment
    Project        = "ML-Network-Anomaly-Detection"
    Purpose        = "Comprehensive-ML-Training-Data"
    DeploymentMode = "ml-focused"
    ManagedBy      = "Terraform"
    CreatedDate    = formatdate("YYYY-MM-DD", timestamp())
    DataTypes      = "Network,Authentication,System,Application,TimeSeries"
  })
}

# ====================================
# FOUNDATION NETWORK INFRASTRUCTURE
# ====================================

module "foundation" {
  source = "../../modules/foundation"

  # Basic configuration
  environment          = var.environment
  vpc_cidr             = local.vpc_cidr
  availability_zones   = local.availability_zones
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs

  # Enhanced features for ML data collection
  enable_nat_instance = true
  nat_instance_ami_id = data.aws_ami.amazon_linux.id
  nat_instance_type   = var.nat_instance_type
  key_name            = var.existing_key_name
  admin_cidr_blocks   = var.admin_cidr_blocks

  # Flow logs
  enable_flow_logs   = var.enable_flow_logs
  flow_logs_role_arn = module.iam.vpc_flow_logs_role_arn

  # Tags
  common_tags = local.common_tags

  depends_on = [module.iam]
}

# ====================================
# IAM ROLES FOR ML INFRASTRUCTURE
# ====================================

module "iam" {
  source = "../../modules/iam"

  # Environment
  environment = var.environment

  # Feature toggles
  enable_flow_logs    = var.enable_flow_logs
  enable_admin_role   = true
  enable_bastion_role = var.enable_bastion
  enable_app_roles    = false
  enable_lambda_roles = false

  # Tags
  common_tags = local.common_tags
}

# ====================================
# ENHANCED ML DATA GENERATORS
# ====================================

module "ml_data_generators" {
  source = "../../modules/ml-generators"

  # Network dependencies
  vpc_id             = module.foundation.vpc_id
  public_subnet_ids  = module.foundation.public_subnet_ids
  private_subnet_ids = module.foundation.private_subnet_ids

  # Basic configuration
  environment       = var.environment
  ami_id            = data.aws_ami.amazon_linux.id
  key_name          = var.existing_key_name
  admin_cidr_blocks = var.admin_cidr_blocks

  # Instance configuration
  web_server_type  = var.web_server_type
  traffic_gen_type = var.traffic_gen_type

  # Enhanced data collection settings
  enable_flow_logs  = var.enable_flow_logs
  enable_cloudwatch = var.enable_cloudwatch_logs

  # Tags
  tags = local.common_tags

  depends_on = [module.foundation]
}

# ====================================
# ENHANCED S3 STORAGE FOR ML DATASETS
# ====================================

module "ml_storage" {
  source = "../../modules/shared"

  # Environment
  environment = var.environment

  # Enhanced S3 Configuration for ML datasets
  bucket_prefix  = var.ml_bucket_prefix
  enable_logging = true
  retention_days = var.s3_retention_days

  # Tags
  common_tags = local.common_tags
}

# ====================================
# OPTIONAL BASTION HOST (If Enabled)
# ====================================

module "bastion_host" {
  count  = var.enable_bastion ? 1 : 0
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
  db_port           = 5432

  # Bastion Configuration
  enable_bastion        = true
  bastion_ami_id        = data.aws_ami.amazon_linux.id
  bastion_instance_type = var.bastion_instance_type
  create_bastion_key    = false
  bastion_public_key    = ""
  existing_key_name     = var.existing_key_name

  # Monitoring
  enable_logging             = true
  enable_detailed_monitoring = var.enable_enhanced_monitoring
  log_retention_days         = var.log_retention_days

  # Network Security
  enable_network_acls = false

  # Tags
  common_tags = local.common_tags

  depends_on = [module.foundation]
} 