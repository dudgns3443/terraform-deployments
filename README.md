## terraform 모듈을 실제 배포하는 레포지토리

현재 레포지토리는 Deployments이며 modules 는 레포지토리를 분리하였습니다. helm chart도 여기에 있습니다.

https://github.com/dudgns3443/terraform-modules

terraform 코드 아키텍처는 멀티계정, 멀티리전을 고려해서 확장성있게 구성했습니다 디렉토리 구성은 아래와 같습니다.

vpc와 eks 는 terraform의 공식 모듈을 활용해 기본 세팅을 provisioning합니다

subnet과 nodegroup은 추후에 더 추가되고 확장성있게 관리하기위해 모듈을 따로 만들었습니다.

```
deployments
    ├── account1
    │   ├── account.hcl               # 계정 전역 설정
    │   ├── global                    # 글로벌 리소스: 리전에 종속되지 않음
    │   │   ├── terragrunt.hcl        # 글로벌 리소스 모듈 호출 설정
    │   │   └── vars.tfvars
    │   ├── ap-northeast-2            # 리전별 디렉토리
    │   │   ├── region.hcl            # 리전 공통 설정
    │   │   ├── prod                  # 환경별 디렉토리
    │   │   │   ├── env.hcl           # 환경별 공통 설정
    │   │   │   ├── vpc
    │   │   │   │   └── terragrunt.hcl
    │   │   │   ├── subnet
    │   │   │   │   └── terragrunt.hcl
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
```
코드는 현재 CompanyAccount1/ap-northeast-2/prod 에만 작성되어있습니다.

nodegroup에 subnet-type: private label을 추가해 subnet 타입을 명시할수 있게했습니다.
해당 label을 통해 deployment에 affinity rule을 추가해

subnet-type: private 인 노드에 배치되도록 만들었습니다.

최상위 에서 
```
terragrunt run-all [init, plan, apply]
```
를 실행하면 모든 리소스가 배포됩니다.

하지만 각 모듈에 들어가서 독립적으로 
```
terragrunt [init, plan, apply]
```
배포하는 것을 권장합니다.

순서는 
```
vpc-basic-prod -> ecr/backend-app -> eks-core-prod(coredns제외) -> nodegroup-domain-app-private -> eks-core-prod(coredns포함) -> helm-ingress-controller -> helm-domain-backend-app-> helm-ingress 
```

순서로 terragrunt init, plan, apply 하면 됩니다!

vpc, ecr, eks, nodegroup 모두 terraform 공식모듈을사용해서 배포했으며 실질적으로 module이 작성된건 helm 모듈 뿐입니다.

terragrunt.hcl에서 모듈 source로 "terraform-aws-modules/vpc/aws?ref=v5.19.0"와 같은 terraform registry 주소가 동작하지않아 source를 공식 모듈 git 주소로 대체했습니다.


애플리케이션(springboot)도 레포지토리를 따로 분리했으며 간단한 CICD 구현해놓았습니다.

https://github.com/dudgns3443/cicd-demo
