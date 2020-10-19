data "template_file" "policy" {
  template = file("./resources/policy.tpl.json")
}
