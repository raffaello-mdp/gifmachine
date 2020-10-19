data "aws_route53_zone" "zone" {
  name = var.route_53_zone
}

data "aws_alb" "alb" {
  name = var.alb_name
}

data "aws_alb_listener" "https" {
  load_balancer_arn = data.aws_alb.alb.arn
  port              = 443
}

data "aws_vpc" "main" {
  tags = {
    Name = "main"
  }
}

data "template_file" "image_lifecycle_policy" {
  template = file("./resources/image_lifecycle_policy.tpl.json")
}

data "template_file" "containers_definition" {
  template = file("./resources/containers_definition.tpl.json")

  vars = {
    log_group     = var.service_name
    region        = var.region
    service_image = var.service_name
    service_name  = var.service_name
  }
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.cluster_name
}

data "aws_iam_role" "ecs_alb_support" {
  name = "AWSServiceRoleForECS"
}

data "aws_iam_role" "salsify_gifmachine_role" {
  name = "SalsifyGifmachineRole"
}
