
data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Environment = "Production"
    Project     = "FinTech"
  }
}

module "organizations" {
  source = "./modules/organizations"
}

module "vpc" {
  source = "./modules/vpc"
  region = var.region
}

module "ecs" {
  source = "./modules/ecs"

  vpc_id           = module.vpc.vpc_id
  private_subnet_a = module.vpc.private_subnet_a
  private_subnet_b = module.vpc.private_subnet_b
  public_subnet_a  = module.vpc.public_subnet_a
  public_subnet_b  = module.vpc.public_subnet_b
}

module "cloudwatch" {
  source     = "./modules/cloudwatch"
  account_id = data.aws_caller_identity.current.account_id
  region     = var.region
}

module "secrets" {
  source = "./modules/secrets"

  account_id = data.aws_caller_identity.current.account_id
  kms_key_id = module.rds.kms_key_id
}

module "rds" {
  source = "./modules/rds"

  vpc_id = module.vpc.vpc_id

  db_subnet_ids = [
    module.vpc.db_subnet_a,
    module.vpc.db_subnet_b
  ]

  ecs_sg_id = module.ecs.ecs_sg_id

  db_master_password = module.secrets.rds_master_password

  tags = local.common_tags
}

module "dynamodb" {
  source    = "./modules/dynamodb"
  kms_key_id = module.rds.kms_key_id
}

module "s3" {
  source    = "./modules/s3"
  kms_key_id = module.rds.kms_key_id
}

module "elasticache" {
  source = "./modules/elasticache"

  vpc_id      = module.vpc.vpc_id
  db_subnet_a = module.vpc.db_subnet_a
  db_subnet_b = module.vpc.db_subnet_b
  ecs_sg_id   = module.ecs.ecs_sg_id

  subnet_ids = [
    module.vpc.db_subnet_a,
    module.vpc.db_subnet_b
  ]

  tags = local.common_tags
}

module "tagging" {
  source = "./modules/tagging"
}
