resource "aws_secretsmanager_secret" "postgres_secret" {
  name = var.db_secret_name
  recovery_window_in_days = var.recovery_window_in_days
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "postgres_secret_version" {
  secret_id = aws_secretsmanager_secret.postgres_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

resource "aws_secretsmanager_secret" "postgres_secret" {
  name = var.keycloak_secret_name
  recovery_window_in_days = var.recovery_window_in_days
  tags = var.tags
}

resource "aws_secretsmanager_secret" "keycloak_admin_secrets" {
  secret_id = aws_secretsmanager_secret.postgres_secret.id
  secret_string = jsonencode({
    username = var.var.keycloak_admin_username
    password = var.var.keycloak_admin_password
  })
}
