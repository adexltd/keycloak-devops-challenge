output "aws_ecr_repository" {
  value = aws_ecr_repository.repo.name
}
output "repository_url" {
  description = "ECR repository URL of Docker image"
  value       = aws_ecr_repository.repo.repository_url
}
