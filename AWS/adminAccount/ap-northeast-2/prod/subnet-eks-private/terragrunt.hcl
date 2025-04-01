include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/subnet"  # private 서브넷만 생성하는 커스텀 모듈
}

dependency "vpc" {
  config_path = "../vpc"  # VPC 모듈의 terragrunt 위치
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  private_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]

  azs = locals.azs

  name = "01-private-eks-subnet-${local.env}"

  tags = merge(local.common_tags, {
    Environment = local.env,
    Region      = local.region
  })
}
