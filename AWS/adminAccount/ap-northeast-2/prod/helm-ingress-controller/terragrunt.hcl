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
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git//modules/eks-managed-node-group?ref=v20.35.0"
}

dependency "eks" {
  config_path = "../eks-core-prod"
}

inputs = {
  release_name = "nginx-ingress"
  namespace    = "ingress-nginx"
  chart        = "ingress-nginx"
  repository   = "https://kubernetes.github.io/ingress-nginx"
  version      = "4.0.13"
  values = [
    <<EOF
controller:
  service:
    type: LoadBalancer
    # 예: 내부 로드밸런서를 원한다면 아래 주석을 제거합니다.
    # annotations:
    #   service.beta.kubernetes.io/aws-load-balancer-internal: "true"
EOF
  ]
  # EKS 모듈에서 출력한 kubeconfig (또는 클러스터 접속 정보를 전달)
  kubeconfig = dependency.eks.outputs.kubeconfig
}