# 1. Baixa o conteúdo da política IAM oficial do repositório da AWS
data "http" "lb_controller_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

# 2. Cria a política IAM na sua conta AWS usando o conteúdo baixado
resource "aws_iam_policy" "lb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for the AWS Load Balancer Controller"
  policy      = data.http.lb_controller_iam_policy.response_body
}

# 3. Cria o Role e anexa a política que acabamos de criar
module "iam_assumable_role_for_service_account" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "aws-load-balancer-controller-role"
  provider_url                  = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  
  # ANTES (Incorreto):
  # role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonEKS_AWS_Load_Balancer_Controller_IAM_Policy"]
  
  # AGORA (Correto): Anexa o ARN da política que o Terraform criou no passo 2
  role_policy_arns              = [aws_iam_policy.lb_controller.arn]

  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
}

# Output para que a pipeline possa usar o ARN do Role
output "lb_controller_role_arn" {
  description = "O ARN do IAM Role para o AWS Load Balancer Controller."
  value       = module.iam_assumable_role_for_service_account.iam_role_arn
}