resource "aws_ecr_repository" "image_repository" {
  name = var.service_name
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  repository = aws_ecr_repository.image_repository.name
  policy     = data.template_file.image_lifecycle_policy.rendered
}

resource "aws_cloudwatch_log_group" "service_log_group" {
  name              = var.service_name
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = var.service_name
  network_mode          = "bridge"
  container_definitions = data.template_file.containers_definition.rendered
  execution_role_arn    = data.aws_iam_role.salsify_gifmachine_role.arn

  # lifecycle {
  #   ignore_changes = [container_definitions]
  # }
}

resource "aws_ecs_service" "service" {
  name          = var.service_name
  cluster       = data.aws_ecs_cluster.cluster.id
  desired_count = 2

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  task_definition = "${aws_ecs_task_definition.task_definition.family}:${aws_ecs_task_definition.task_definition.revision}"

  iam_role = data.aws_iam_role.ecs_alb_support.arn

  load_balancer {
    target_group_arn = aws_alb_target_group.service_target_group.arn
    container_name   = "${var.service_name}-api"
    container_port   = "80"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "host"
  }
}
