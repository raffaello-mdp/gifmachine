resource "aws_security_group" "private_rds" {
  name        = "postgres-sg"
  description = "Allow traffic to port 5432 from inside the vpc"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name      = "postgres-sg"
    Tier      = "salsify"
    CreatedBy = "GlobalAdmin"
  }
}

resource "aws_security_group_rule" "allow_egress_sg" {
  security_group_id = aws_security_group.private_rds.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ingress_sg" {
  security_group_id = aws_security_group.private_rds.id
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

module "instance" {
  source = "terraform-aws-modules/rds/aws"

  identifier                = "main"
  name                      = "main"
  deletion_protection       = false
  engine                    = "postgres"
  instance_class            = "db.t2.micro"
  engine_version            = "9.6.9"
  family                    = "postgres9.6"
  major_engine_version      = "9.6"
  allocated_storage         = 5
  storage_encrypted         = false
  final_snapshot_identifier = "main-before-deletion"

  username = "main_master"
  password = aws_ssm_parameter.main_master_password.value
  port     = "5432"

  vpc_security_group_ids = [aws_security_group.private_rds.id]
  subnet_ids             = data.aws_subnet_ids.private_subnets.ids

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  backup_retention_period         = 7
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    Tier      = "infra"
    CreatedBy = "GlobalAdmin"
  }
}

resource "aws_route53_record" "instance_cname" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.host_name
  type    = "CNAME"
  ttl     = "30"

  records = [module.instance.this_db_instance_address]
}
