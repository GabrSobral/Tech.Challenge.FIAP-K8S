resource "aws_internet_gateway" "igw_tech_challenge" {
  # Conecta à sua VPC criada no vpc.tf
  vpc_id = aws_vpc.vpc_tech_challenge.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Integração com a Lambda de Auth (precisará ler o ARN da Lambda via remote state do Repo 1)
# Integração com o Load Balancer do K8s (via VPC Link)