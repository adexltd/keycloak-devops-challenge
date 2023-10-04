data "aws_caller_identity" "current" {} 

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "3.18.0"
  name                         = "${var.name}-vpc"
  cidr                         = "10.0.0.0/16"
  private_subnets              = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets               = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  database_subnets             = ["10.0.5.0/24", "10.0.6.0/24"]
  azs                          = slice(data.aws_availability_zones.available.names, 0, 3)
  create_database_subnet_group = true
  database_subnet_suffix       = "db"
  enable_nat_gateway           = true
  single_nat_gateway           = true
  one_nat_gateway_per_az       = false
}

module "postgres_secrets_manager" {
  source      = "./modules/secrets"
  db_secret_name = "postgres-credentials-keycloak"
  keycloak_secret_name = "keycloak-admin-credentials"
  recovery_window_in_days = 0
  # These Credentials are to be rotated
  db_username = "keycloak"
  db_password = "secrectpassword"
  keycloak_admin_username = "admin"
  keycloak_admin_password = "secrectpassword"
}

module "rds" {
  source = "./modules/rds"
  db_name                           = "${var.name}-db"
  db_instance_class                 = "db.t2.micro"
  db_engine                         = "postgres"
  db_engine_version                 = "11"
  db_allocated_storage              = 20
  db_subnet_group_name              = "${var.name}-subnet-group"
  db_parameter_group_name           = "${var.name}-parameter-group"
  db_multi_az                       = false
  db_backup_retention_period        = 7
  db_port                           = 5432
  db_subnet_ids                     = module.vpc.database_subnets
  cidr_blocks_to_allow_access_to_db = module.vpc.private_subnets_cidr_blocks
  vpc_id                            = module.vpc.vpc_id
  db_secret_name                    = module.postgres_secrets_manager.postgres_secret_name
  depends_on = [module.postgres_secrets_manager]
}



module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.name
  # builder_repository_name="keycloak_builder"
  depends_on           = [module.vpc, module.rds, module.postgres_secrets_manager]
}

module "alb" {
  source = "./modules/alb"

  alb_name          = "${var.name}-alb"
  listener_port     = 80
  target_group_name = "${var.name}-target-group"
  target_group_port = 8080
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnets
  depends_on        = [module.vpc, module.rds, module.postgres_secrets_manager]
}

# Push Docker Image to registry

module "keycloak_fargate" {
  source = "./modules/fargate"

  fargate_service_name = var.name
  ecs_cluster_name     = var.name
  image                = module.ecr.repository_url
  container_port       = 8080
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnets
  alb_target_group_arn = module.alb.target_group_arn
  alb_listener_arn     = module.alb.aws_lb_listener
  source_cidr_blocks   = module.vpc.public_subnets_cidr_blocks
  db_secret_name       = module.postgres_secrets_manager.postgres_secret_name
  db_endpoint          = module.rds.db_hostname
  project_domain_name  = var.domain_name
  desired_count        = 3
  depends_on           = [module.postgres_secrets_manager, module.ecr]
}

resource "aws_route53_record" "record_keyclaok" {
  type    = "CNAME"
  name    = var.domain_name
  ttl     = "300"
  zone_id = "Z03028901EPUSX1K65JBK"
  records = [module.alb.alb_dns_name]
}
