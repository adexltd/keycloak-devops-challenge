resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/ecs/cluster/${var.ecs_cluster_name}"
  retention_in_days = var.retention_in_days
  tags              = var.tags
}
