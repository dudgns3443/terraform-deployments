locals {
    profile = "default"
}

generate "backend" {
  path      = "backend.tf"    # 모듈 실행 시 자동 생성될 provider 설정 파일
  if_exists = "overwrite"       # 이미 파일이 있다면 덮어씁니다.
  contents  = <<EOF
terraform {
  backend "s3" {}
}
EOF
}


remote_state {
  backend = "s3"
  config  = {
    profile = "default"                              # 계정마다 다른profile이용
    bucket         = "st.terraform-state-bucket"     # 계정마다 다른 bucket이름 이용
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks"
  }
}
