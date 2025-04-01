include "root" { 
    path = find_in_parent_folders("root.hcl")
    expose = true
}

include "account" {
    path = find_in_parent_folders("account.hcl")
    expose = true
}

include "region" {
    path = find_in_parent_folders("region.hcl")
    expose = true
}

include "env" {
    path = find_in_parent_folders("env.hcl")
    expose = true
}

locals {
  company = include.root.locals.company
  profile = include.account.locals.profile
  region  = include.region.locals.region
  azs     = include.region.locals.azs
  env     = include.env.locals.env
  cidr    = include.env.locals.cidr
  tags    = include.root.locals.common_tags
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecr.git?ref=v2.4.0"
}

inputs = {
  repository_name = "backend-app"
  region = local.region
  
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration = {
    scan_on_push = false
  }

  create_lifecycle_policy = false

  # 태그 설정 (필요에 따라 수정)
  tags = merge(local.tags, {
    Environment = local.env,
    Region      = local.region,
  })
}