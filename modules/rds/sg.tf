resource "aws_security_group" "rds_security_group" {
  name        = "keycloak-db-sg"
  description = "RDS PostGress security group"
  vpc_id      = var.vpc_id
  tags        = var.db_tags
}


resource "aws_security_group_rule" "rds_security_group_postgress" {
  type              = "ingress"
  security_group_id = aws_security_group.rds_security_group.id

  from_port   = var.db_port
  to_port     = var.db_port
  protocol    = "TCP"
  cidr_blocks = var.cidr_blocks_to_allow_access_to_db
}

resource "aws_security_group_rule" "rds_security_group_egress" {
  security_group_id = aws_security_group.rds_security_group.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
