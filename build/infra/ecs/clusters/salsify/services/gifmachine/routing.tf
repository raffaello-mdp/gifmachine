resource "aws_route53_record" "service_record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.service_alias
  type    = "A"

  alias {
    name                   = data.aws_alb.alb.dns_name
    zone_id                = data.aws_alb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_alb_target_group" "service_target_group" {
  name                 = var.service_name
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.main.id
  deregistration_delay = 30

  health_check {
    interval          = 10
    path              = "/"
    matcher           = "200"
    timeout           = 2
    healthy_threshold = 3
  }

  stickiness {
    cookie_duration = 86400
    enabled         = true
    type            = "lb_cookie"
  }

  tags = {
    Name      = var.service_name
    Tier      = "salsify"
    CreatedBy = "GlobalAdmin"
  }
}

resource "aws_alb_listener_rule" "service_listener_rule" {
  listener_arn = data.aws_alb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.service_target_group.arn
  }

  condition {
    host_header {
      values = [var.service_alias]
    }
  }
}
