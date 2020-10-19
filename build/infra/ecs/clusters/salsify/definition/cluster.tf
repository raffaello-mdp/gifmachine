resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name

  tags = {
    Name      = var.cluster_name
    Tier      = "salsify"
    CreatedBy = "GlobalAdmin"
  }
}

resource "aws_security_group" "cluster_sg" {
  name        = "${var.cluster_name}-ecs-asg-sg"
  description = "Allow HTTP/HTTPS from ALB"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name      = var.cluster_name
    Tier      = "salsify"
    CreatedBy = "GlobalAdmin"
  }
}

resource "aws_security_group_rule" "allow_egress_sg" {
  security_group_id = aws_security_group.cluster_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ingress_non_tls_sg" {
  security_group_id        = aws_security_group.cluster_sg.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.allow_http.id
}

resource "aws_security_group_rule" "allow_ingress_tls_sg" {
  security_group_id        = aws_security_group.cluster_sg.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.allow_http.id
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = data.aws_iam_role.ec2_for_ecs_role.name
}

resource "aws_key_pair" "salsify_instance_key_pair_access" {
  key_name   = var.cluster_name
  public_key = data.aws_ssm_parameter.salsify_instance_publickey.value
}

resource "aws_launch_configuration" "cluster_lc" {
  name_prefix = "${var.cluster_name}-ecs-lc"

  image_id             = data.aws_ami.aws_optimized_ecs.id
  instance_type        = var.instance_type
  key_name             = aws_key_pair.salsify_instance_key_pair_access.key_name
  security_groups      = [aws_security_group.cluster_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name

  user_data = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cluster_asg" {
  name = "${var.cluster_name}-ecs-asg"

  vpc_zone_identifier = data.aws_subnet_ids.private_subnets.ids

  launch_configuration = aws_launch_configuration.cluster_lc.name

  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  termination_policies = ["OldestInstance", "OldestLaunchConfiguration"]

  health_check_grace_period = 60
  health_check_type         = "EC2"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-ecs"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "salsify"
    propagate_at_launch = true
  }

  tag {
    key                 = "CreatedBy"
    value               = "GlobalAdmin"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "asg_scale_out_on_mem_res" {
  name                   = "asg-scale-out-on-mem-res"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.cluster_asg.name
}

resource "aws_autoscaling_policy" "asg_scale_in_on_mem_res" {
  name                   = "asg-scale-in-on-mem-res"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.cluster_asg.name
}
