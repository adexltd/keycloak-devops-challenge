resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.alb.id]
  tags               = var.tags
}

resource "aws_lb_target_group" "target_group" {
  name        = var.target_group_name
  port        = var.target_group_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/health"
    port                = 8080
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 100
    matcher             = "200-499"
    timeout             = 30
  }
  stickiness {
    cookie_duration = "86400"
    cookie_name     = "AUTH_SESSION_ID"
    enabled         = true
    type            = "lb_cookie"
  }
  tags = var.tags
}

resource "aws_security_group" "alb" {
  name_prefix = "alb"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-2:426857564226:certificate/f53ef742-9dae-4c8e-b76d-1b0ba1cda8c5" #need to change based upon the profile
  depends_on        = [aws_lb_target_group.target_group]

  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }
}



