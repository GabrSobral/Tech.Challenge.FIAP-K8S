# Output do ID da VPC (para ser usado pelo DB e Lambda)
output "vpc_id" {
  value = aws_vpc.vpc_tech_challenge.id 
}

# Output das Subnets (para ser usado pelo DB e Lambda)
output "subnet_ids" {
  value = aws_subnet.subnet_public[*].id
}

# Output do Security Group Base (se necessário)
output "security_group_id" {
  value = aws_security_group.security_group.id
}

# # Outputs for EKS Cluster and ECR Repository
output "ecr_repository_url" {
  description = "A URL do repositório ECR"
  value       = aws_ecr_repository.app_repository.repository_url
}
output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}