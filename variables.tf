variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "tech-challenge"
}

variable "new_relic_license_key" {
  description = "Chave de licença de Ingestão do New Relic"
  type        = string
  sensitive   = true  # Isso impede que a chave apareça nos logs do terminal
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type for the EKS worker nodes"
  type        = string
  default     = "t3.small"
}