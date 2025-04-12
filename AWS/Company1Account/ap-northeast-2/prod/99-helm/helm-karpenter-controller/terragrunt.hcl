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
  source = "git::https://github.com/dudgns3443/terraform-modules.git//helm?ref=master"
}

dependency "eks" {
  config_path = "../../eks-core-prod"
}

dependency "karpenter_iam" {
  config_path = "../../../../global/iam/apn2-eks-irsa"
}

inputs = {
  #클러스터 정보
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_ca_certificate = dependency.eks.outputs.cluster_certificate_authority_data
  cluster_name                       = dependency.eks.outputs.cluster_name

  release_name            = "karpenter"
  namespace               = "karpenter"
  chart_version           = "1.3.3"  # 사용하고자 하는 차트 버전
  repo_url                = "oci://public.ecr.aws/karpenter/"
  chart_name              = "karpenter"         
  values                  = [
    <<EOF
serviceAccount:
  create: true
  name: karpenter
  annotations:
    eks.amazonaws.com/role-arn: "${dependency.karpenter_iam.outputs.iam_role_arn}"  # Karpenter Controller Role

settings:
  clusterName: "${dependency.eks.outputs.cluster_name}"
  clusterEndpoint: "${dependency.eks.outputs.cluster_endpoint}"

# 예시: EC2 인스턴스 프로필, Controller 리소스 requests
controller:
  resources:
    requests:
      cpu: "1"
      memory: "1Gi"
EOF
  ]
}
