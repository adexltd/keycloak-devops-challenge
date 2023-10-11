resource "aws_secretsmanager_secret" "keycloak_secret" {
  name = var.keycloak_secret_name
  recovery_window_in_days = var.recovery_window_in_days
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "keycloak_secret_version" {
  secret_id = aws_secretsmanager_secret.keycloak_secret.id
  secret_string = jsonencode({
    db_username = var.db_username
    db_password = var.db_password
    keycloak_admin_username = var.keycloak_admin_username
    keycloak_admin_password = var.keycloak_admin_password
    certificate_arn_us-east-1 = var.certificate_arn_us-east-1
    certificate_arn_us-east-2 = var.certificate_arn_us-east-2
  })
}
