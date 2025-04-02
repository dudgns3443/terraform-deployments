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
  # source = "git::https://github.com/dudgns3443/terraform-modules.git//helm?ref=main"
  source = "../../../../../../terraform-modules/helm"
}

dependency "eks" {
  config_path = "../eks-core-prod"
}

inputs = {
  #클러스터 정보
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_ca_certificate = dependency.eks.outputs.cluster_certificate_authority_data
  cluster_name                       = dependency.eks.outputs.cluster_name

  release_name            = "backend-app"
  namespace               = "domain" 
  chart_name              = "./charts/app-chart"
  values = [
    <<EOF
autoscaling:
  enabled: true
image:
  url: 534420079206.dkr.ecr.ap-northeast-2.amazonaws.com/backend-app
  pullPolicy: Always
  tag: latest
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: "subnet_type"
              operator: In
              values:
                - "private"
EOF
  ]
}
