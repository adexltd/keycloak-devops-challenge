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
  enable_execute_command = true   ###Enabled for ssm

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

  type        = "ingress"
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
  task_role_arn      = aws_iam_role.default.arn

  container_definitions = jsonencode([{
    name  = "keycloak"
    image = var.image
    environment = [
        { "name" : "KC_LOG_LEVEL", "value": "INFO"},
        { "name" : "KC_FEATURES", "value": "step-up-authentication,admin-fine-grained-authz,scripts,token-exchange,declarative-user-profile,dynamic-scopes,client-secret-rotation,recovery-codes,update-email" },
        { "name" : "KC_HEALTH_ENABLED", "value": "true" },
        { "name" : "KC_METRICS_ENABLED", "value": "true" },
        { "name" : "KC_CACHE_CONFIG_FILE", "value": "cache-ispn-jdbc-ping.xml" },
        { "name" : "KC_HTTP_ENABLED", "value": "false" },
        { "name" : "KC_HTTP_RELATIVE_PATH", "value": "/" },
        { "name" : "KC_DB_URL", "value" : "jdbc:postgresql://${var.db_endpoint}:5432/keycloak" },
        { "name" : "KC_DB", "value" : "postgres" },
        { "name" : "KC_PROXY", "value" : "edge" },
        { "name" : "KC_HOSTNAME_STRICT", "value" : "false" },
        { "name" : "KC_HOSTNAME_STRICT_BACKCHANNEL", "value" : "false" },
        { "name" : "KC_DB_SCHEMA", "value" : "public" },
        { "name" : "KC_HOSTNAME_URL", "value" : "https://${var.project_domain_name}" },
        { "name" : "KC_HOSTNAME_ADMIN_URL", "value" : "https://${var.project_domain_name}" },
        { "name" : "KC_DB_USERNAME", "value" : "${jsondecode(data.aws_secretsmanager_secret_version.keycloak_current_secrets.secret_string)["db_username"]}" },
        { "name" : "KC_DB_PASSWORD", "value" : "${jsondecode(data.aws_secretsmanager_secret_version.keycloak_current_secrets.secret_string)["db_password"]}" },
        { "name" : "KEYCLOAK_ADMIN", "value" : "${jsondecode(data.aws_secretsmanager_secret_version.keycloak_current_secrets.secret_string)["keycloak_admin_username"]}" },
        { "name" : "KEYCLOAK_ADMIN_PASSWORD", "value" : "${jsondecode(data.aws_secretsmanager_secret_version.keycloak_current_secrets.secret_string)["keycloak_admin_password"]}" }

    ]

    health_check = {
      command     = ["CMD-SHELL", "curl -f ${var.project_domain_name}/health || exit 1"]
      interval    = 60
      startPeriod = 300
      retries     = 2
      timeout     = 5
    }
    portMappings = [{
      containerPort = var.container_port,
      hostPort      = var.container_port,
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group : "/ecs/keycloak"
        awslogs-region : "us-east-2"
        awslogs-stream-prefix : "ecs"
      }
    }
  }])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  tags                     = merge({ "Name" = var.fargate_service_name }, var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "default" {

  name               = local.iam_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  path               = "/"
  description        = "IAM role for ECS task"
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
      "ecs:ExecuteCommand",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
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
