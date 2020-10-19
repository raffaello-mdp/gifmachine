resource "aws_ssm_parameter" "salsify_instance_privatekey" {
  name        = "/salsify/instance/privatekey"
  description = "Private key used to access salsify instances"
  type        = "SecureString"
  value       = "-"

  tags = {
    Tier      = "salsify"
    CreatedBy = "GlobalAdmin"
  }

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "salsify_instance_publickey" {
  name        = "/salsify/instance/publickey"
  description = "Public key used to access salsify instances"
  type        = "SecureString"
  value       = "-"

  tags = {
    Tier      = "salsify"
    CreatedBy = "GlobalAdmin"
  }

  lifecycle {
    ignore_changes = [value]
  }
}
