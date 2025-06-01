module "vpc" {
  source               = "./modules/vpc"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

module "gateways" {
  source            = "./modules/gateway"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets_ids
  vpc_cidr          = module.vpc.vpc_cidr
  nat_instance_ami  = var.nat_instance_ami
}

module "routing" {
  source              = "./modules/routing"
  vpc_id              = module.vpc.vpc_id
  igw_id              = module.gateways.internet_gateway_id  
  public_subnet_ids   = module.vpc.public_subnets_ids
  private_subnet_ids  = module.vpc.private_subnets_ids
  nat_instance_eni_id = module.gateways.nat_instance_eni_id
}

module "security" {
  source               = "./modules/security"
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnets_ids
  private_subnet_ids   = module.vpc.private_subnets_ids
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "bastion" {
  source           = "./modules/bastion"
  count            = var.enable_bastion ? 1 : 0

  bastion_ami      = var.bastion_ami
  public_subnet_id = module.vpc.public_subnets_ids[0]
  ssh_key_name     = var.ssh_key_name
  my_ip_cidr       = var.my_ip_cidr
}

module "web_server" {
  source           = "./modules/web_server"
  count            = var.web_server_enabled ? 1 : 0

  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnets_ids[0]
  ami_id           = var.web_server_ami
  instance_type    = var.web_server_instance_type
  key_name         = var.ssh_key_name
  bastion_sg_id    = var.enable_bastion ? module.bastion[0].bastion_sg_id : null
  
}

module "aws_subnet" {
  source                = "./modules/vpc"
  public_subnet_cidrs   = var.private_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  azs                   = var.azs
  
}

