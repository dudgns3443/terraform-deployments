include {
  path = find_in_parent_folders()
}

locals {
  region = "ap-northeast-2"
  azs = [
    "${local.region}a",
    "${local.region}c"
  ]
}

