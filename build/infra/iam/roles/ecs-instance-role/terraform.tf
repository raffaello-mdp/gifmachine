terraform {
  backend "s3" {
    bucket         = "rmdp-tf-remote-state"
    key            = "iam/roles/ecs-instance-role/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock"
    profile        = "global-admin"
  }
}
