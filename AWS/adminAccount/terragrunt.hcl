include {
  path = find_in_parent_folders()
}

terraform {
  backend "s3" {
    bucket         = "ST.terraform-state-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks"
  }
}

locals {
  profile  = "default"
  common_tags = {
    Owner     = "team-spoon"
    ManagedBy = "terragrunt"
  }
}
