terraform {
  backend "s3" {
    bucket         = "rmdp-tf-remote-state"
    key            = "iam/users/github-deployer/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock"
    profile        = "global-admin"
  }
}
