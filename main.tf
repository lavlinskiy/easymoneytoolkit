module "vpc" {
  source = "./modules/vpc"
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "ec2_instance" {
  source             = "./modules/ec2_instance"
  ami                = var.instance_ami
  instance_type      = var.instance_type
  subnet_id          = module.vpc.public_subnet_id
  security_group_ids = [module.security_groups.instance_sg_id]
  public_key         = var.public_key
  ec2_ssh_public_key = var.ec2_ssh_public_key
  ec2_private_key    = var.ec2_private_key
}

