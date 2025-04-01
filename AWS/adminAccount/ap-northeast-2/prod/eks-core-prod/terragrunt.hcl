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
  # 공식 EKS 클러스터 모듈을 호출 registy에서 안받아와져서 git 공식주소를 사용
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git//?ref=v20.35.0"
}

dependency "vpc" {
  config_path = "../vpc-basic-prod"
}


inputs = {
  cluster_name    = "${local.company}-eks-core-${local.env}"
  cluster_version = "1.32"

  # EKS 클러스터에서 사용할 서브넷과 VPC ID
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = concat(
    dependency.vpc.outputs.public_subnets,
    dependency.vpc.outputs.private_subnets
  )

  cluster_endpoint_public_access = true

  # IRSA(Instance Role for Service Accounts) 활성화 및 로그 유형 지정
  enable_irsa               = true
  cluster_enabled_log_types = ["api", "audit", "authenticator"]
  
  # 기본 애드온 
  cluster_addons = {
    coredns   = { most_recent = true } # coredns는 노드그룹 만든 후에 적용하는게 좋다. 먼저만들면 timeout됨
    kube-proxy = { most_recent = true }
    vpc-cni   = { most_recent = true }
  }

  # 엑세스 권한 부여
  access_entries = {
    admin = {
      principal_arn = "arn:aws:iam::534420079206:user/yh.kim"

      policy_associations = {
        adminview = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"
          access_scope = {
            type = "cluster"
          }
        }
        clusterAdmin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    }
  }

  # 태그: 상위 계층(account 등)에서 선언한 공통 태그에 환경과 리전 정보를 병합
  tags = merge(local.tags, {
    Environment = local.env,
    Region      = local.region,
    Project     = "${local.company}-eks-cluster"
  })
}