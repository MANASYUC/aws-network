module "vpc" {
  source               = "./modules/vpc"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  azs                  = ["us-east-1a", "us-east-1b"]
}

module "gateways" {
  source            = "./modules/gateway"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
}

module "routing" {
  source              = "./modules/routing"
  vpc_id              = module.vpc.vpc_id
  igw_id              = module.gateways.internet_gateway_id
  public_subnet_ids   = module.vpc.public_subnets
  private_subnet_ids  = module.vpc.private_subnets
  nat_gateway_ids     = module.gateways.nat_gateway_ids
}

module "security" {
  source               = "./modules/security"
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnets
  private_subnet_ids   = module.vpc.private_subnets
  private_subnet_cidrs = var.private_subnet_cidrs
}

