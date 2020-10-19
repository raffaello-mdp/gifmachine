resource "aws_ssm_parameter" "salsify_gifmachine_database_url" {
  name        = "/salsify/gifmachine/databaseurl"
  description = "Url used by the service to connect to the database with the format postgres://username:password@database-url:5432/database-name."
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

resource "aws_ssm_parameter" "salsify_gifmachine_api_password" {
  name        = "/salsify/gifmachine/apipassword"
  description = "Password to make requests to the secured apis"
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
