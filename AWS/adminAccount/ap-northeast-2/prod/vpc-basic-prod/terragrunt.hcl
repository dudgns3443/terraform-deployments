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
  # Terraform Registry의 공식 VPC 모듈을 사용 registy에서 안받아와져서 git 공식주소를 사용
#   source = "terraform-aws-modules/vpc/aws?ref=v5.19.0" 
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//?ref=v5.19.0"

}

inputs = {
  name = "${local.company}-vpc-${local.region}-${local.env}"
  cidr_block = local.cidr
  region     = local.region
  env        = local.env
  
  cidr = local.cidr

  azs = local.azs

  public_subnets  = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnets  = [
    "10.0.10.0/24",
    "10.0.20.0/24"
  ]

  # NAT Gateway 설정: 여러 NAT Gateway를 생성할 경우 false, 단일 NAT Gateway 사용 시 true로 설정
  enable_nat_gateway = true
  single_nat_gateway = false

  # VPN Gateway 설정 (필요하지 않으면 false)
  enable_vpn_gateway = false

  # env, region 정보를 병합하여 태그로 전달
  tags = merge(local.tags, {
    Environment = local.env,
    Region      = local.region,
  })
}