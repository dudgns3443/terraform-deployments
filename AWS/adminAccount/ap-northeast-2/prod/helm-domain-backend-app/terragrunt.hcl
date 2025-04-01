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
  release_name = "my-app"
  namespace    = "default"
  chart        = "my-app-chart"
  repository   = "https://charts.example.com/"  # 여러분의 애플리케이션 헬름 차트가 저장된 저장소
  version      = "0.1.0"
  values = [
    <<EOF
replicaCount: 2
image:
  repository: my-app-image
  tag: latest
service:
  type: ClusterIP
  port: 8080
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: "nginx"
  hosts:
    - host: myapp.example.com
      paths:
        - /
EOF
  ]
  kubeconfig = dependency.eks.outputs.kubeconfig
}