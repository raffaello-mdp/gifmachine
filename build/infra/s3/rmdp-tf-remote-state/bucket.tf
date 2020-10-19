resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = {
    Name      = var.bucket_name
    Tier      = "infra"
    CreatedBy = "GlobalAdmin"
  }

  policy = data.template_file.policy.rendered

  force_destroy = true
}
