output "postgres_secret_arn" {
  value = aws_secretsmanager_secret.postgres_secret.arn
}
output "postgres_secret_name" {
  value = var.secret_name
}
