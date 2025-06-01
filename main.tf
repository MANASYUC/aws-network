module "vpc" {
  source               = "./modules/vpc"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

module "aws_subnet" {
  source                = "./modules/vpc"
  public_subnet_cidrs   = var.private_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  azs                   = var.azs
  
}

module "gateways" {
  source            = "./modules/gateway"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets_ids
  vpc_cidr          = module.vpc.vpc_cidr
  nat_instance_ami  = var.ami_id
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
  my_ip_cidr           = var.my_ip_cidr
  app_server_subnet_cidr = module.app_server.subnet_id
}

module "bastion" {
  source           = "./modules/bastion"
  count            = var.enable_bastion ? 1 : 0

  bastion_ami      = var.ami_id
  public_subnet_id = module.vpc.public_subnets_ids[0]
  ssh_key_name     = var.ssh_key_name
  my_ip_cidr       = var.my_ip_cidr
}

module "web_server" {
  source           = "./modules/servers/web"
  count            = var.enable_web_server ? 1 : 0

  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnets_ids[0]
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  key_name         = var.ssh_key_name
  bastion_sg_id    = var.enable_bastion ? module.bastion[0].bastion_sg_id : null
  
}


module "app_server" {
  source            = "./modules/servers/app"
  count             = var.enable_app_server ? 1 : 0 

  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = module.vpc.private_subnet_ids[0]
  key_name          = var.ssh_key_name
  security_group_id = module.security.app_sg_id
}

module "db_server" {
  source            = "./modules/servers/db"
  count             = var.enable_db_server ? 1 : 0

  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = module.vpc.private_subnet_ids[0]
  key_name          = var.ssh_key_name
  security_group_id = module.security.db_sg_id
}

module "traffic_client" {
  source            = "./modules/traffic_client"
  count             = var.enable_traffic ? 1 : 0 

  ami_id            = var.ami_id      # Amazon Linux 2 AMI in your region
  instance_type     = var.instance_type
  subnet_id         = module.vpc.private_subnet_ids[0]
  key_name          = var.ssh_key_name
  security_group_id = module.security.traffic_client_sg
  target_url        = "http://<your-app-server-private-ip-or-dns>"
}



