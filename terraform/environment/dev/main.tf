module "network" {
  source = "../../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr = "10.0.101.0/24"
  az = "eu-central-1a"
}

module "security_groups" {
  source = "../../modules/security-group"
  vpc_id = module.network.vpc_id
}

module "ec2" {
  source = "../../modules/ec2"
  private_subnet_id = module.network.private_subnet_id
  public_subnet_id = module.network.public_subnet_id
  ami_id = "ami-0b6c6ebed2801a5cb"
  instance_type = "t3.micro"
  alb_sg_group_id = module.security_groups.alb_security_group_id
  app_sg_group_id = module.security_groups.app_security_group_id
  jenkins_sg_group_id = module.security_groups.jenkins_security_group_id
  devkey = "devkey.pem"
}