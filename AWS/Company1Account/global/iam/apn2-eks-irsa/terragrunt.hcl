include "root" { 
    path = find_in_parent_folders("root.hcl")
    expose = true
}

include "account" {
    path = find_in_parent_folders("account.hcl")
    expose = true
}

locals {
  company = include.root.locals.company
  profile = include.account.locals.profile
  tags    = include.root.locals.common_tags
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role-with-oidc?ref=v5.54.1"
}

dependency "eks" {
  config_path = "../../../ap-northeast-2/prod/03-eks-core-prod"
}

inputs = {
  # create_role: IAM Role을 실제로 생성할지 여부
  create_role = true

  # provider_url: OIDC Provider URL, EKS의 OIDC Issuer URL을 Dependency로부터 가져옴
  provider_url = dependency.eks.outputs.cluster_oidc_issuer_url

  # role_name: 생성될 IAM Role의 이름
  role_name = "KarpenterControllerRole"

  # role_policy_arns: Role에 붙일 AWS 관리형 정책(또는 커스텀 Policy ARN)
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]

  # inline_policy_statements: inline policy를 JSON 문법의 policy document 형태로 추가 가능
  # 최소 권한 원칙에 따라 필요한 액션만 열어주는 Custom Policy를 정의할 수 있음
  inline_policy_statements = [
    {
      # Karpenter 예: Instance Lifecycle 관련 권한만 지정
      sid = "KarpenterMinimalPolicy"
      actions = [
        "ec2:DescribeInstances",
        "ec2:TerminateInstances",
        "ec2:RunInstances",
        "ec2:DescribeImages",
        "iam:GetInstanceProfile",
        "iam:CreateInstanceProfile",
        "iam:TagInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:PassRole",
        "pricing:GetProducts"
      ]
      resources = ["*"]
    }
  ]

  # oidc_fully_qualified_subjects:
  #   "system:serviceaccount:<namespace>:<serviceaccount>"를 완전히 써줘야 함
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:karpenter:karpenter"
  ]

  # 그 외 태그 등
  tags = merge(
    {
      "Name"    = "KarpenterControllerRole",
      "Project" = "Karpenter"
    },
    local.tags
  )
}