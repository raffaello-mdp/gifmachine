data "template_file" "assume_policy" {
  template = file("./resources/assume_policy.tpl.json")
}

data "template_file" "policy" {
  template = file("./resources/policy.tpl.json")
}
