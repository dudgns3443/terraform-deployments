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
  config_path = "../../03-eks-core-prod"
}

dependency "backend-app" {
  config_path = "../helm-domain-backend-app"
}

inputs = {
  #클러스터 정보
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_ca_certificate = dependency.eks.outputs.cluster_certificate_authority_data
  cluster_name                       = dependency.eks.outputs.cluster_name

  release_name            = "ingress-app"
  namespace               = "domain" 
  chart_name              = "./charts/app-chart"
  values = [
    <<EOF
ingress:
  enabled: true
  hosts:
  - host: backendcore.conects.com
    paths:
    - path: /
      pathType: Prefix
      backend:
        service:
          name: ${dependency.backend-app.outputs.app_name}
          port:
            number: 80
EOF
  ]
}
