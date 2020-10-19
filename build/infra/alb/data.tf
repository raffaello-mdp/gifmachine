data "aws_acm_certificate" "cert" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

data "aws_vpc" "main" {
  tags = {
    Name      = "main"
    Tier      = "infra"
    CreatedBy = "GlobalAdmin"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Public = "true"
  }
}
