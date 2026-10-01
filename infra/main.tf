locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
    Course    = "devops-prova-1bimestre"
  }
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  tags         = local.common_tags
}

module "security_group" {
  source            = "./modules/security-group"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  ssh_allowed_cidr  = var.ssh_allowed_cidr
  tags              = local.common_tags
}

module "ec2" {
  source             = "./modules/ec2"
  project_name       = var.project_name
  public_subnet_id   = module.vpc.public_subnet_ids[0]
  security_group_id  = module.security_group.ec2_sg_id
  public_key_path    = "${path.module}/chave-prova.pub"
  tags               = local.common_tags
}

module "rds" {
  source             = "./modules/rds"
  project_name       = var.project_name
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security_group.rds_sg_id
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  tags               = local.common_tags
}
