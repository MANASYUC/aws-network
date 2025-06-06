# ====================================
# NEW IMPROVED MAIN CONFIGURATION
# ====================================
# This demonstrates the new layered architecture:
# Layer 1: Foundation (Network Infrastructure)
# Layer 2: Platform (Security & Management)  
# Layer 3: Applications (Workloads)
# ====================================

# Data sources for dynamic values
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

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ====================================
# LOCAL VARIABLES
# ====================================

locals {
  # Environment configuration
  environment = var.environment

  # Network configuration
  vpc_cidr             = var.vpc_cidr
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  # Common tags applied to all resources
  common_tags = merge(var.common_tags, {
    Environment = local.environment
    Project     = "AWS-Network-Architecture"
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  })
}

# ====================================
# LAYER 0: IAM (IDENTITY AND ACCESS MANAGEMENT)
# ====================================

module "iam" {
  source = "./modules/iam"

  # Environment
  environment = local.environment

  # Feature toggles - IAM roles created based on what's enabled
  enable_flow_logs    = var.enable_flow_logs
  enable_admin_role   = var.enable_bastion || var.enable_web_tier || var.enable_app_tier || var.enable_data_tier
  enable_bastion_role = var.enable_bastion
  enable_app_roles    = var.enable_app_tier
  enable_lambda_roles = false # Set to true when Lambda functions are added

  # Tags
  common_tags = local.common_tags
}

# ====================================
# LAYER 1: FOUNDATION (NETWORK INFRASTRUCTURE)
# ====================================

module "foundation" {
  source = "./modules/foundation"

  # Environment
  environment = local.environment

  # Network Configuration
  vpc_cidr             = local.vpc_cidr
  availability_zones   = local.availability_zones
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs

  # Feature toggles
  enable_nat_instance = var.enable_nat_instance
  enable_flow_logs    = var.enable_flow_logs

  # NAT Instance Configuration
  nat_instance_ami_id = data.aws_ami.amazon_linux.id
  nat_instance_type   = var.nat_instance_type
  key_name            = var.existing_key_name
  admin_cidr_blocks   = var.admin_cidr_blocks

  # IAM Dependencies
  flow_logs_role_arn = module.iam.vpc_flow_logs_role_arn

  # Tags
  common_tags = local.common_tags

  # Explicit dependency
  depends_on = [module.iam]
}

# ====================================
# LAYER 2: PLATFORM (SECURITY & MANAGEMENT)
# ====================================

module "platform" {
  source = "./modules/platform"

  # Dependencies from foundation layer
  vpc_id             = module.foundation.vpc_id
  public_subnet_ids  = module.foundation.public_subnet_ids
  private_subnet_ids = module.foundation.private_subnet_ids

  # Environment
  environment = local.environment

  # Security Configuration
  admin_cidr_blocks = var.admin_cidr_blocks
  app_port          = var.app_port
  db_port           = var.db_port

  # Bastion Configuration
  enable_bastion        = var.enable_bastion
  bastion_ami_id        = data.aws_ami.amazon_linux.id
  bastion_instance_type = var.bastion_instance_type
  create_bastion_key    = var.create_bastion_key
  bastion_public_key    = var.bastion_public_key
  existing_key_name     = var.existing_key_name

  # Monitoring
  enable_logging             = var.enable_logging
  enable_detailed_monitoring = var.enable_detailed_monitoring
  log_retention_days         = var.log_retention_days

  # Network Security
  enable_network_acls = var.enable_network_acls

  # Tags
  common_tags = local.common_tags

  # Explicit dependency
  depends_on = [module.foundation]
}

# ====================================
# LAYER 3: APPLICATIONS (OPTIONAL)
# ====================================

# Web Tier - Public facing web servers
module "web_tier" {
  source = "./modules/applications/web-tier"
  count  = var.enable_web_tier ? 1 : 0

  # Dependencies
  vpc_id            = module.foundation.vpc_id
  subnet_ids        = module.foundation.public_subnet_ids
  security_group_id = module.platform.web_tier_security_group_id

  # Configuration
  environment    = local.environment
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
  source = "./modules/applications/app-tier"
  count  = var.enable_app_tier ? 1 : 0

  # Dependencies  
  vpc_id            = module.foundation.vpc_id
  subnet_ids        = module.foundation.private_subnet_ids
  security_group_id = module.platform.app_tier_security_group_id

  # Configuration
  environment    = local.environment
  instance_count = var.app_instance_count
  instance_type  = var.app_instance_type
  ami_id         = data.aws_ami.amazon_linux.id
  key_name       = var.existing_key_name
  app_port       = var.app_port

  # Tags
  common_tags = local.common_tags

  depends_on = [module.platform]
}

# Data Tier - Database servers
module "data_tier" {
  source = "./modules/applications/data-tier"
  count  = var.enable_data_tier ? 1 : 0

  # Dependencies
  vpc_id            = module.foundation.vpc_id
  subnet_ids        = module.foundation.private_subnet_ids
  security_group_id = module.platform.db_tier_security_group_id

  # Configuration
  environment   = local.environment
  instance_type = var.db_instance_type
  ami_id        = data.aws_ami.amazon_linux.id
  key_name      = var.existing_key_name
  db_port       = var.db_port

  # Storage
  enable_encryption = var.enable_db_encryption
  backup_retention  = var.db_backup_retention

  # Tags
  common_tags = local.common_tags

  depends_on = [module.platform]
}

# ====================================
# SHARED SERVICES (OPTIONAL)
# ====================================

# S3 Buckets for logging and storage
module "shared_storage" {
  source = "./modules/shared"
  count  = var.enable_shared_storage ? 1 : 0

  environment    = local.environment
  bucket_prefix  = var.s3_bucket_prefix
  enable_logging = var.enable_s3_logging
  retention_days = var.s3_retention_days

  common_tags = local.common_tags
}
