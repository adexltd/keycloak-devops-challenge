data "aws_caller_identity" "current" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  project_name = "keycloak"
  region       = "us-east-1"
  owner        = "Roshan Raman Giri"
  domain_name  = "keycoak.aawajai.com"
  env          = "dev"
  local_tags = {
    Environment = "Development"
    owner       = "Roshan Raman Giri"
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

# Need to configure S3 backend.

# Need to configure route 53 

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "3.18.0"
  name                         = "${local.project_name}-vpc"
  cidr                         = "10.0.0.0/16"
  private_subnets              = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets               = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  database_subnets             = ["10.0.5.0/24", "10.0.6.0/24"]
  azs                          = ["${local.region}a", "${local.region}b", "${local.region}c"]
  create_database_subnet_group = true
  database_subnet_suffix       = "db"
  enable_nat_gateway           = true
  single_nat_gateway           = true
  one_nat_gateway_per_az       = false
}

module "postgres_secrets_manager" {
  source      = "./modules/secrets"
  secret_name = "postgres-credentials-keycloak1111"
  # These Credentials are to be rotated
  db_username = "keycloak"
  db_password = "secrectpassword"
  tags = {
    Name        = "${local.project_name}-secrets"
    Environment = "${local.env}"
    owner       = "${local.owner}"
  }
}

module "rds" {
  source = "./modules/rds"

  db_name                           = "${local.project_name}-db"
  db_instance_class                 = "db.t2.micro"
  db_engine                         = "postgres"
  db_engine_version                 = "11"
  db_allocated_storage              = 20
  db_subnet_group_name              = "${local.project_name}-subnet-group"
  db_parameter_group_name           = "${local.project_name}-parameter-group"
  db_multi_az                       = false
  db_backup_retention_period        = 7
  db_port                           = 5432
  db_subnet_ids                     = module.vpc.database_subnets
  cidr_blocks_to_allow_access_to_db = module.vpc.private_subnets_cidr_blocks
  vpc_id                            = module.vpc.vpc_id
  db_secret_name                    = module.postgres_secrets_manager.postgres_secret_name
  db_tags = {
    Name        = "${local.project_name}-db"
    Environment = "${local.env}"
    owner       = "${local.owner}"
  }

  depends_on = [module.postgres_secrets_manager]
}



module "ecr" {
  source          = "./modules/ecr"
  repository_name = "keycloak"
  tags = {
    Name        = "${local.project_name}-ecr"
    Environment = "${local.env}"
    owner       = "${local.owner}"
  }
  depends_on           = [module.vpc, module.rds, module.postgres_secrets_manager]
}

module "alb" {
  source = "./modules/alb"

  alb_name          = "keycloak-alb"
  listener_port     = 80
  target_group_name = "keycloak-target-group"
  target_group_port = 8080
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnets
  depends_on        = [module.vpc, module.rds, module.postgres_secrets_manager]
  tags = {
    Name        = "${local.project_name}-alb"
    Environment = "${local.env}"
    owner       = "${local.owner}"
  }
}

# Push Docker Image to registry

module "keycloak_fargate" {
  source = "./modules/fargate"

  fargate_service_name = "keycloak"
  ecs_cluster_name     = "keycloak"
  image                = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/keycloak:latest"
  container_port       = 8080
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnets
  alb_target_group_arn = module.alb.target_group_arn
  alb_listener_arn     = module.alb.aws_lb_listener
  source_cidr_blocks   = module.vpc.public_subnets_cidr_blocks
  db_secret_name       = module.postgres_secrets_manager.postgres_secret_name
  db_endpoint          = module.rds.db_hostname
  project_domain_name  = local.domain_name
  desired_count        = 3
  depends_on           = [module.postgres_secrets_manager, module.ecr]
  tags = {
    Name        = "${local.project_name}-fargate"
    Environment = "${local.env}"
    owner       = "${local.owner}"
  }
}
