data "aws_vpc" "main" {
  tags = {
    Name = "main"
  }
}

data "aws_security_group" "allow_http" {
  name = "allow_http"
}

data "template_file" "user_data" {
  template = file("./resources/user-data.tpl.sh")

  vars = {
    cluster_name = aws_ecs_cluster.cluster.name
  }
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Public = "false"
    Tier   = "infra"
  }
}

data "aws_iam_role" "ec2_for_ecs_role" {
  name = "EcsInstanceRole"
}

data "aws_ssm_parameter" "salsify_instance_publickey" {
  name = "/salsify/instance/publickey"
}

data "aws_ami" "aws_optimized_ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["591542846629"] # AWS
}
