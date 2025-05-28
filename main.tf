module "vpc" {
  source               = "./modules/vpc"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
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

module "bastion" {
  source           = "./modules/bastion"
  count            = var.enable_bastion ? 1 : 0

  bastion_ami      = var.bastion_ami
  public_subnet_id = aws_subnet.public[0].id
  ssh_key_name     = var.ssh_key_name
  my_ip_cidr       = var.my_ip_cidr
}

module "web_server" {
  source           = "./modules/web_server"
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnet_ids[0]
  ami_id           = var.web_server_ami
  instance_type    = var.web_server_instance_type
  key_name         = var.ssh_key_name
  bastion_sg_id    = module.bastion.bastion_sg_id
  enabled          = var.web_server_enabled
}


