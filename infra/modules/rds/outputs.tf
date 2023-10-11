output "db_hostname" {
  value       = aws_db_instance.rds_instance.address
  description = "Database Hostname"
}
output "db_arn" {
  value       = aws_db_instance.rds_instance.arn
  description = "Database ARN"
}
output "db_endpoint" {
  value       = aws_db_instance.rds_instance.endpoint
  description = "Database Endpoint"
}