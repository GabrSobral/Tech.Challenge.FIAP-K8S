# infra/ecr.tf

# Cria o repositório no Amazon ECR
resource "aws_ecr_repository" "app_repository" {
  name                 = "tech-challenge-repo" # O nome do seu repositório
  image_tag_mutability = "IMMUTABLE"           # Ou IMMUTABLE, que é mais seguro para produção

  image_scanning_configuration {
    scan_on_push = true # Ativa o scan de vulnerabilidades no push
  }
}

# Define uma política de ciclo de vida para limpar imagens antigas
resource "aws_ecr_lifecycle_policy" "app_repo_policy" {
  repository = aws_ecr_repository.app_repository.name

  # A política abaixo remove imagens sem tags que tenham mais de 14 dias
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire untagged images older than 14 days"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 14
      }
      action = {
        type = "expire"
      }
    }]
  })
}