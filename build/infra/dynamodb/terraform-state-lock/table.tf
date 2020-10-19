resource "aws_dynamodb_table" "table" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = "terraform-lock"
    Tier      = "infra"
    CreatedBy = "GlobalAdmin"
  }
}
