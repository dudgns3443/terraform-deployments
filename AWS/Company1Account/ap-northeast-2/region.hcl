locals {
  region = "ap-northeast-2"
  azs = [
    "${local.region}a",
    "${local.region}c"
  ]
}