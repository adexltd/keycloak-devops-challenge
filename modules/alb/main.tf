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
  certificate_arn   = "arn:aws:acm:us-east-1:426857564226:certificate/3fc0c3bc-90f6-4600-bcd5-6ffeb59db6db" #need to change based upon the profile
  depends_on        = [aws_lb_target_group.target_group]

  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }
}

# Request and validate an SSL certificate from AWS Certificate Manager (ACM)
# resource "aws_acm_certificate" "keycloak-certificate" {
#   domain_name       = "keycloak-alb-565685615.us-east-1.elb.amazonaws.com"
#   validation_method = "DNS"


#   tags = {
#     Name = "SSL certificate"
#   }
# }

# resource "aws_lb_listener_certificate" "https_additional_certs" {
#   listener_arn    = aws_lb_listener.https.arn
#   certificate_arn = aws_acm_certificate.keycloak-certificate.arn
# }

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = var.certificate_arn
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.keycloak.arn
#   }
# }


