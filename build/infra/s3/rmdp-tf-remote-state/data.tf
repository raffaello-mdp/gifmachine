data "aws_iam_role" "global_admin" {
  name = "GlobalAdmin"
}

data "template_file" "policy" {
  template = file("./resources/policy.tpl.json")

  vars = {
    bucket_name       = var.bucket_name
    global_admin_role = data.aws_iam_role.global_admin.arn
  }
}
