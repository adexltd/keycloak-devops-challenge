resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_ids
  tags       = var.db_tags
}

resource "aws_db_parameter_group" "rds_parameter_group" {
  name   = var.db_parameter_group_name
  family = "${var.db_engine}${var.db_engine_version}"

  parameter {
    apply_method = "pending-reboot"
    name         = "max_connections"
    value        = "1000"
  }

  tags = var.db_tags
}
resource "aws_db_instance" "rds_instance" {
  identifier                 = var.db_name
  allocated_storage          = var.db_allocated_storage
  engine                     = var.db_engine
  engine_version             = var.db_engine_version
  instance_class             = var.db_instance_class
  db_name                    = "keycloak"
  username                   = jsondecode(data.aws_secretsmanager_secret_version.current_secrets.secret_string)["db_username"]
  password                   = jsondecode(data.aws_secretsmanager_secret_version.current_secrets.secret_string)["db_password"]
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name       = aws_db_parameter_group.rds_parameter_group.name
  multi_az                   = var.db_multi_az
  skip_final_snapshot        = true
  backup_retention_period    = var.db_backup_retention_period
  port                       = var.db_port
  vpc_security_group_ids     = [aws_security_group.rds_security_group.id]
  auto_minor_version_upgrade = true
  tags                       = var.db_tags
}
