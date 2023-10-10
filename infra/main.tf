data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "3.18.0"
  name                         = "${var.name}-vpc"
  cidr                         = "10.0.0.0/16"
  private_subnets              = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets               = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  database_subnets             = ["10.0.5.0/24", "10.0.6.0/24"]
  azs                          = slice(data.aws_availability_zones.available.names, 0, 3)
  tags                         = var.tags
  create_database_subnet_group = true
  database_subnet_suffix       = "db"
  enable_nat_gateway           = true
  single_nat_gateway           = true
  one_nat_gateway_per_az       = false
}

module "secrets_manager" {
  source                  = "./modules/secrets"
  keycloak_secret_name    = "postgres-credentials-keycloak"
  recovery_window_in_days = 0
  # These Credentials are to be rotated
  db_username               = var.db_username
  db_password               = var.db_password
  keycloak_admin_username   = var.keycloak_admin_username
  keycloak_admin_password   = var.keycloak_admin_password
  certificate_arn_us-east-1 = var.certificate_arn_us-east-1
  certificate_arn_us-east-2 = var.certificate_arn_us-east-2
  tags                      = var.tags
}

module "rds" {
  source                            = "./modules/rds"
  db_name                           = "${var.name}-db"
  db_instance_class                 = var.db_instance_class
  db_engine                         = "postgres"
  db_engine_version                 = "11"
  db_allocated_storage              = var.db_storage_size
  db_subnet_group_name              = "${var.name}-subnet-group"
  db_parameter_group_name           = "${var.name}-parameter-group"
  db_multi_az                       = var.db_multi_az
  db_backup_retention_period        = 7
  db_port                           = var.db_port
  db_subnet_ids                     = module.vpc.database_subnets
  cidr_blocks_to_allow_access_to_db = module.vpc.private_subnets_cidr_blocks
  vpc_id                            = module.vpc.vpc_id
  keycloak_secret_name              = module.secrets_manager.keycloak_secret_name
  db_tags                           = var.tags
  depends_on                        = [module.secrets_manager]
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.name
  # builder_repository_name="keycloak_builder"
  tags       = var.tags
  depends_on = [module.vpc, module.rds, module.secrets_manager]
}

module "alb" {
  source               = "./modules/alb"
  alb_name             = "${var.name}-alb"
  listener_port        = 80
  target_group_name    = "${var.name}-target-group"
  target_group_port    = var.container_port
  vpc_id               = module.vpc.vpc_id
  region               = var.region
  subnet_ids           = module.vpc.public_subnets
  keycloak_secret_name = module.secrets_manager.keycloak_secret_name
  depends_on           = [module.vpc, module.rds, module.secrets_manager]
  tags                 = var.tags
}

# Push Docker Image to registry

module "keycloak_fargate" {
  source               = "./modules/fargate"
  fargate_service_name = var.name
  ecs_cluster_name     = var.name
  image                = "${module.ecr.repository_url}:latest"
  container_port       = var.container_port
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnets
  alb_target_group_arn = module.alb.target_group_arn
  alb_listener_arn     = module.alb.aws_lb_listener
  source_cidr_blocks   = module.vpc.public_subnets_cidr_blocks
  keycloak_secret_name = module.secrets_manager.keycloak_secret_name
  db_endpoint          = module.rds.db_hostname
  project_domain_name  = var.domain_name
  desired_count        = var.container_desired_count
  depends_on           = [module.secrets_manager, module.ecr]
  tags                 = var.tags
}

resource "aws_route53_record" "record_keyclaok" {
  type    = "CNAME"
  name    = var.domain_name
  ttl     = "300"
  zone_id = var.zone_id
  records = [module.alb.alb_dns_name]
}
