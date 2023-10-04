data "aws_secretsmanager_secret" "by_name" {
  name = var.keycloak_secret_name
}

data "aws_secretsmanager_secret_version" "current_secrets" {
  secret_id = data.aws_secretsmanager_secret.by_name.id
}
