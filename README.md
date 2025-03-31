## terraform 모듈을 실제 배포하는 레포지토리

terraform 코드 아키텍처는 멀티계정, 멀티리전을 고려해서 확장성있게 구성했습니다 디렉토리 구성은 아래와 같습니다.

현재 레포지토리는 Deployments구조를 참조하시면되고 modules 는 레포지토리를 분리하였습니다.

flowchart TD
    A[Root]
    A --> B[modules]
    A --> C[deployments]

    %% Modules 구조
    B --> B1[global]
    B1 --> B1a[iam]
    B1 --> B1b[route53]
    B1 --> B1c[cloudfront]
    B --> B2[vpc]
    B --> B3[subnet]
    B --> B4[eks]
    B --> B5[nodegroup]
    B --> B6[helm-alb-ingress]
    B --> B7[helm-app]

    %% Deployments 구조 - Account Level
    C --> D1[account1]
    C --> D2[account2]

    %% account1 구조
    D1 --> D1a[terragrunt.hcl]
    D1 --> D1b[global]
    D1b --> D1b1[terragrunt.hcl]
    D1b --> D1b2[vars.tfvars]
    D1 --> D1c[us-east-1]
    D1 --> D1d[eu-west-1]

    %% us-east-1 구조 (account1)
    D1c --> D1c1[terragrunt.hcl]
    D1c --> D1c2[dev]
    D1c --> D1c3[stag]
    D1c --> D1c4[prod]

    %% dev 환경 (us-east-1, account1)
    D1c2 --> D1c2a[vpc]
    D1c2a --> D1c2a1[terragrunt.hcl]
    D1c2a --> D1c2a2[vars.tfvars]
    D1c2 --> D1c2b[subnet]
    D1c2b --> D1c2b1[terragrunt.hcl]
    D1c2b --> D1c2b2[vars.tfvars]
    D1c2 --> D1c2c[eks]
    D1c2c --> D1c2c1[terragrunt.hcl]
    D1c2c --> D1c2c2[vars.tfvars]
    D1c2 --> D1c2d[nodegroup]
    D1c2d --> D1c2d1[terragrunt.hcl]
    D1c2d --> D1c2d2[vars.tfvars]
    D1c2 --> D1c2e[helm-alb-ingress]
    D1c2e --> D1c2e1[terragrunt.hcl]
    D1c2e --> D1c2e2[vars.tfvars]
    D1c2 --> D1c2f[helm-app]
    D1c2f --> D1c2f1[terragrunt.hcl]
    D1c2f --> D1c2f2[vars.tfvars]

    %% (stag, prod 및 eu-west-1, account2 등은 위와 유사한 구조)
