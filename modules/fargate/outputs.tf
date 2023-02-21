output "fargate_service_name" {
  value = aws_ecs_service.default.name
}

output "fargate_service_arn" {
  value = aws_ecs_service.default.id
}
