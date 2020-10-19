resource "aws_ssm_parameter" "main_master_password" {
  name        = "/rds/instances/main/master/password"
  description = "Password to access main instace as master user"
  type        = "SecureString"
  value       = "-"

  tags = {
    Tier      = "infra"
    CreatedBy = "GlobalAdmin"
  }

  lifecycle {
    ignore_changes = [value]
  }
}
