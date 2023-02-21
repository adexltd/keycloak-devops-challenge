locals {
  iam_name            = "${var.fargate_service_name}-iam-role"
  security_group_name = "${var.fargate_service_name}-security-group"
  container_name      = "${var.fargate_service_name}-container"
}
resource "aws_ecs_service" "default" {
  name             = var.fargate_service_name
  cluster          = aws_ecs_cluster.keycloak.id
  task_definition  = aws_ecs_task_definition.default.arn
  desired_count    = var.desired_count
  platform_version = "LATEST"
  launch_type      = "FARGATE"

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.default.id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "keycloak"
    container_port   = var.container_port
  }
}
resource "aws_security_group" "default" {

  name   = local.security_group_name
  vpc_id = var.vpc_id
  tags   = merge({ "Name" = local.security_group_name }, var.tags)
}

resource "aws_security_group_rule" "ingress" {

  type              = "ingress"
  from_port         = var.container_port
  to_port           = var.container_port
  protocol          = "tcp"
  cidr_blocks       = var.source_cidr_blocks
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "egress" {

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}
resource "aws_ecs_task_definition" "default" {
  family             = var.fargate_service_name
  execution_role_arn = aws_iam_role.default.arn
  container_definitions = jsonencode([{
    name  = "keycloak"
    image = var.image
    environment = [
      { "name" : "DB_VENDOR", "value" : "postgres" },
      { "name" : "DB_ADDR", "value" : var.db_endpoint },
      { "name" : "DB_PORT", "value" : "5432" },
      { "name" : "DB_USER", "value" : "${jsondecode(data.aws_secretsmanager_secret_version.current_secrets.secret_string)["username"]}" },
      { "name" : "DB_PASSWORD", "value" : "${jsondecode(data.aws_secretsmanager_secret_version.current_secrets.secret_string)["password"]}" },
      { "name" : "DB_DATABASE", "value" : "keycloak" },
    ]
    # secrets = [
    #   {
    #     "valueFrom" : "${data.aws_secretsmanager_secret_version.current_secrets.arn}:username",
    #     "name" : "DB_USER"
    #   }
    # ]
    portMappings = [{
      containerPort = var.container_port,
      hostPort      = var.container_port,
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group : "/ecs/keycloak"
        awslogs-region : "us-east-1"
        awslogs-stream-prefix : "ecs"
      }
    }
  }])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  tags                     = merge({ "Name" = var.fargate_service_name }, var.tags)
}

resource "aws_iam_role" "default" {

  name               = local.iam_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  path               = "/"
  description        = "Iam role for ECS task"
  tags               = merge({ "Name" = local.iam_name }, var.tags)
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_policy" "default" {
  name        = "${local.iam_name}-policy"
  policy      = data.aws_iam_policy.ecs_task_execution.policy
  path        = "/"
  description = "IAM policy for fargate service"
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}


data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "fargate" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["logs:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "additional" {
  name        = "${local.iam_name}-policy-additional"
  policy      = data.aws_iam_policy_document.fargate.json
  path        = "/"
  description = "IAM policy for fargate service"
}
resource "aws_iam_role_policy_attachment" "additional" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.additional.arn
}


resource "aws_cloudwatch_log_group" "yada" {
  name              = "/ecs/keycloak"
  retention_in_days = 30
  tags              = merge({ "Name" = local.iam_name }, var.tags)
}
