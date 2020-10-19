resource "aws_route53_zone" "rmdptk" {
  name = "rmdp.tk"

  tags = {
    Name      = "rmdp.tk"
    Tier      = "infra"
    CreatedBy = "GlobalAdmin"
  }
}
