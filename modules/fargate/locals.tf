data "aws_secretsmanager_secret" "keycloak" {
  name = var.keycloak_secret_name
}

data "aws_secretsmanager_secret_version" "keycloak_current_secrets" {
  secret_id = data.aws_secretsmanager_secret.keycloak.id
}
