resource "aws_iam_role" "role" {
  name               = var.name
  path               = "/"
  assume_role_policy = data.template_file.assume_policy.rendered

  tags = {
    Name      = var.name
    Tier      = "infra"
    CreatedBy = "GlobalAdmin"
  }
}

resource "aws_iam_policy" "policy" {
  name   = "${var.name}Policy"
  policy = data.template_file.policy.rendered
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}
