# CONFIGURAÇÃO CORRETA: Credenciais direto no provider, sem bloco 'kubernetes' aninhado
provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_cluster.name]
      command     = "aws"
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  
  # Timeout maior para evitar falhas em instalações lentas
  timeout    = 600

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.node_group
  ]

  set = [ 
    {
      name  = "clusterName"
      value = aws_eks_cluster.eks_cluster.name
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.iam_assumable_role_for_service_account.iam_role_arn
    }
  ]
}

resource "helm_release" "newrelic" {
  name       = "newrelic-bundle"
  repository = "https://helm-charts.newrelic.com"
  chart      = "nri-bundle"
  namespace  = "newrelic"
  create_namespace = true

  set = [
    {
      name  = "global.licenseKey"
      value = var.new_relic_license_key # Use variável, não hardcode!
    },
    {
      name  = "global.cluster"
      value = "TechChallenge-Cluster"
    },
    {
      name  = "kubeEvents.enabled"
      value = "true"
    },
    {
      name  = "logging.enabled"
      value = "true"
    }
  ]
}