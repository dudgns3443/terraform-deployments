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
#   relative_path = path_relative_to_include()
#   path_parts = split("/", local.relative_path)
  company = include.root.locals.company
  profile = include.account.locals.profile
  region  = include.region.locals.region
  azs     = include.region.locals.azs
  env     = include.env.locals.env
  cidr    = include.env.locals.cidr
  tags    = include.root.locals.common_tags
}



terraform {
  # 공식 EKS 클러스터 모듈을 호출
  source = "terraform-aws-modules/eks/aws//modules/eks-cluster?ref=v20.13.1"
}

dependency "vpc" {
  config_path = "../vpc-basic-prod"
}


inputs = {
  cluster_name    = "${local.company}-eks-core-${local.env}"
  cluster_version = "1.32"

  # EKS 클러스터에서 사용할 서브넷과 VPC ID
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets

  # IRSA(Instance Role for Service Accounts) 활성화 및 로그 유형 지정
  enable_irsa               = true
  cluster_enabled_log_types = ["api", "audit", "authenticator"]

  # 기본 애드온(예: CoreDNS, kube-proxy, vpc-cni)을 최신 버전으로 사용
  cluster_addons = {
    coredns   = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni   = { most_recent = true }
  }

  # 태그: 상위 계층(account 등)에서 선언한 공통 태그에 환경과 리전 정보를 병합
  tags = merge(local.common_tags, {
    Environment = local.env,
    Region      = local.region,
    Project     = "${local.company}-eks-cluster"
  })
}