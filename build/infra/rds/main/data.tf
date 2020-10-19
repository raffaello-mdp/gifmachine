data "aws_vpc" "main" {
  tags = {
    Name = "main"
  }
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Public = "false"
    Tier   = "infra"
  }
}

data "aws_route53_zone" "zone" {
  name = var.route_53_zone
}
