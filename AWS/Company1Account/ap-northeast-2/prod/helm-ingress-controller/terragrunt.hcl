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
  source = "git::https://github.com/dudgns3443/terraform-modules.git//helm?ref=v1.1"
}

dependency "eks" {
  config_path = "../eks-core-prod"
}

inputs = {
  #클러스터 정보
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_ca_certificate = dependency.eks.outputs.cluster_certificate_authority_data
  cluster_name                       = dependency.eks.outputs.cluster_name

  release_name            = "ingress-nginx"
  namespace               = "ingress-nginx"
  chart_version           = "4.9.1"  # 사용하고자 하는 ALB Ingress Controller Helm 차트 버전
  repo_url                = "https://kubernetes.github.io/ingress-nginx"
  chart_name              = "ingress-nginx"         
}
