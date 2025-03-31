terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks"
  }
}

locals {
  profile  = "admin"
  common_tags = {
    Owner     = "team-spoon"
    ManagedBy = "terragrunt"
  }
}
