module "network" {
  source = "../../modules/vpc"
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs = var.azs
}

module "security_groups" {
  source = "../../modules/security-group"
  vpc_id = module.network.vpc_id
}

module "ec2" {
  source = "../../modules/ec2"
  private_subnet_id = module.network.private_subnet_id
  public_subnet_id = module.network.public_subnet_id
  ami_id = var.ami_id
  instance_type = var.instance_type
  alb_sg_group_id = module.security_groups.alb_security_group_id
  app_sg_group_id = module.security_groups.app_security_group_id
  jenkins_sg_group_id = module.security_groups.jenkins_security_group_id
  devkey = var.devkey
}

module "alb" {
  source = "../../modules/alb"
  public_subnet_id = module.network.public_subnet_id
  private_subnet_id = module.network.private_subnet_id
  alb_security_group_id = module.security_groups.alb_security_group_id
  vpc_id = module.network.vpc_id
  app_instance_id = module.ec2.instance_id
  depends_on = [module.ec2]
}

module "monitoring" {
  source = "../../modules/monitoring"
  app_instance_id = module.ec2.instance_id
  alert_email = var.alert_email
  tg_arn_suffix  = module.alb.tg_arn_suffix
  alb_arn_suffix = module.alb.alb_arn_suffix
}