include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/dudgns3443/terraform-modules.git//subnets?ref=main" 
}

dependency "vpc" {
  config_path = "../vpc-basic-prod"  # VPC 모듈의 terragrunt 파일 위치
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  # EKS와 NodeGroup이 사용할 Private Subnet CIDR 목록
  subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
  gateway_ids = dependency.vpc.outputs.nat_gateway_ids
  azs = local.azs

  # 서브넷 리소스 이름
  name_prefix = "${local.company}-eks-core-nodeGroup-${local.env}"

  # 상위에서 선언한 공통 태그와 환경, 리전 정보를 병합
  tags = merge(local.common_tags, {
    Environment = local.env,
    Region      = local.region,
    Project     = "spoon-eks-cluster"
  })
}