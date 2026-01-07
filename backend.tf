terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket = "tech-challenge-fiap-s3-bucket"
    key    = "infra-k8s/terraform.tfstate"
    region = "us-east-1"
  }
}