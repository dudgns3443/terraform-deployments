include {
  path = find_in_parent_folders()
}

locals {
  env   = "prod"
  cidr  = "10.0.0.0/16"  
}