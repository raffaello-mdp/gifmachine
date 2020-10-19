data "aws_caller_identity" "current" {}

data "template_file" "assume_policy" {
  template = file("./resources/assume_policy.tpl.json")
}

data "template_file" "policy" {
  template = file("./resources/policy.tpl.json")

  vars = {
    account_id = data.aws_caller_identity.current.account_id
    region     = var.region
  }
}
