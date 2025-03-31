## terraform 모듈을 실제 배포하는 레포지토리


현재 레포지토리는 Deployments이며 modules 는 레포지토리를 분리하였습니다.
https://github.com/dudgns3443/terraform-modules
terraform 코드 아키텍처는 멀티계정, 멀티리전을 고려해서 확장성있게 구성했습니다 디렉토리 구성은 아래와 같습니다.


deployments
    ├── account1
    │   ├── terragrunt.hcl         # 계정 전역 설정
    │   ├── global                # 글로벌 리소스: 리전에 종속되지 않음
    │   │   ├── terragrunt.hcl     # 글로벌 리소스 모듈 호출 설정
    │   │   └── vars.tfvars
    │   ├── ap-northeast-2            # 리전별 디렉토리
    │   │   ├── terragrunt.hcl     # 리전 공통 설정
    │   │   ├── prod              # 환경별 디렉토리
    │   │   │   ├── vpc
    │   │   │   │   ├── terragrunt.hcl
    │   │   │   │   └── vars.tfvars
    │   │   │   ├── subnet
    │   │   │   │   ├── terragrunt.hcl
    │   │   │   │   └── vars.tfvars
    │   │   │   ├── eks
    │   │   │   ├── nodegroup
    │   │   │   ├── helm-alb-ingress
    │   │   │   └── helm-app
    │   │   ├── stag
    │   │   │   └── … (구조 동일)
    │   │   └── dev
    │   │       └── … (구조 동일)
    │   ├── us-east-1            # 다른 리전 디렉토리
    │   │   └── … (구조 동일)
    └── account2
        └── … (account1과 동일한 구조)

코드는 account1/ap-northeast-2/prod 에서만 동작합니다

