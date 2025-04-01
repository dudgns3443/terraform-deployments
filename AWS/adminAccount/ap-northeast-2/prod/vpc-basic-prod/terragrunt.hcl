include {
  path = find_in_parent_folders()
}

terraform {
  # Terraform Registry의 공식 VPC 모듈을 사용합니다
  source = "terraform-aws-modules/vpc/aws?ref=v3.14.2"  
}

inputs = {
  name = "vpc-${local.region}-${local.env}"
  cidr_block = local.cidr
  region     = local.region
  env        = local.env
  
  # 최상위 env 레벨에서 정의한 CIDR 값을 사용 (예: "10.0.0.0/16")
  cidr = local.cidr

  # 현재 리전(local.region) 기준으로 가용 영역(AZ) 접미사를 붙여 AZ 목록 생성
  azs = [
    "${local.region}a",
    "${local.region}c",
  ]

  public_subnets  = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  # NAT Gateway 설정: 여러 NAT Gateway를 생성할 경우 false, 단일 NAT Gateway 사용 시 true로 설정
  enable_nat_gateway = true
  single_nat_gateway = false

  # VPN Gateway 설정 (필요하지 않으면 false)
  enable_vpn_gateway = false

  # 상위 계층(account 레벨)에서 선언한 공통 태그(local.common_tags)와
  # env, region 정보를 병합하여 태그로 전달
  tags = merge(local.common_tags, {
    Environment = local.env,
    Region      = local.region,
  })
}