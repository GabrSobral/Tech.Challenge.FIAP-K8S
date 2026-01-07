resource "aws_security_group" "security_group" {
  name        = "${var.project_name}-sg"
  description = "Usado para expor o nginx"
  vpc_id      = aws_vpc.vpc_tech_challenge.id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Cria um Security Group (firewall) para o banco de dados
resource "aws_security_group" "db_sg" {
  name        = "database-sg"
  description = "Allow Database traffic"
  vpc_id      = aws_vpc.vpc_tech_challenge.id

  # Regra de entrada (ingress): Libera a porta 5432 (Postgres)
  # Neste exemplo, estamos liberando para qualquer IP da VPC. 
  # Em produção, você limitaria para o Security Group da sua aplicação.
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc_tech_challenge.cidr_block]
  }

  # Regra de saída (egress): Libera todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "postgres-sg"
  }
}