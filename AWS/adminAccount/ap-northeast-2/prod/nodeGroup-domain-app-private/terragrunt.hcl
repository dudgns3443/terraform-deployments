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
dependency "vpc" {
  config_path = "../vpc-basic-prod"
}

inputs = {
  cluster_name   = dependency.eks.outputs.cluster_name
  subnet_ids     = dependency.vpc.outputs.private_subnets

  name           = "domain-backend-app-private-nodegroup"
  name_prefix    = "domain-backend-app-private"
  iam_role_use_name_prefix = false
  instance_types = ["t3.medium"]

  desired_capacity = 1
  min_capacity     = 1
  max_capacity     = 1
  capacity_type    = "ON_DEMAND"

  update_config = {
    max_unavailable = 1
  }

  labels = {
    subnet_type = "private"
    role        = "worker"
  }

  taints = [
    {
        key    = "subnet_type"
        value  = "private"
        effect = "NO_SCHEDULE"
    }
  ]

  disk_size = 20

  create                 = true
  cluster_service_cidr   = "10.100.0.0/16"

  tags = merge(local.tags, {
      Environment = local.env,
      Region      = local.region,
      NodeGroup   = "backend-app-ng"
    }
  )
}