resource "aws_iam_user" "github_deployer" {
  name = var.name
  path = "/"

  tags = {
    Name      = var.name
    Tier      = "infra"
    CreatedBy = "GlobalAdmin"
  }
}

resource "aws_iam_access_key" "github_deployer" {
  user = aws_iam_user.github_deployer.name
}

resource "aws_iam_policy" "policy" {
  name   = "${var.name}Policy"
  policy = data.template_file.policy.rendered
}

resource "aws_iam_user_policy_attachment" "github_deployer-policy-attach" {
  user       = aws_iam_user.github_deployer.name
  policy_arn = aws_iam_policy.policy.arn
}
