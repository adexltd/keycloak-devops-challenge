output "keycloak_secret_arn" {
  value = aws_secretsmanager_secret.keycloak_secret.arn
}
output "keycloak_secret_name" {
  value = var.keycloak_secret_name
}
