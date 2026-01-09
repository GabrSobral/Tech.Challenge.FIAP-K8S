# # 1. O API Gateway (Tipo HTTP é mais barato e moderno que REST)
# resource "aws_apigatewayv2_api" "main_gateway" {
#   name          = "tech-challenge-gateway"
#   protocol_type = "HTTP"
# }

# # 2. O Stage (Ambiente, ex: default)
# resource "aws_apigatewayv2_stage" "default" {
#   api_id      = aws_apigatewayv2_api.main_gateway.id
#   name        = "$default"
#   auto_deploy = true
# }

# # 3. Security Group para o VPC Link (Permite entrada do API Gateway)
# resource "aws_security_group" "vpc_link_sg" {
#   name        = "api-gateway-vpc-link-sg"
#   description = "SG para o VPC Link do API Gateway"
#   vpc_id      = aws_vpc.vpc_tech_challenge.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Ou restrinja aos IPs do API Gateway se possível
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # 4. O VPC Link (A ponte para dentro da VPC)
# resource "aws_apigatewayv2_vpc_link" "eks_link" {
#   name               = "eks-vpc-link"
#   security_group_ids = [aws_security_group.vpc_link_sg.id]
#   subnet_ids         = aws_subnet.subnet_private[*].id # Conecta nas subnets privadas onde seus nós estão
# }

# # 5. A Rota (Exemplo: redirecionar /pedidos para o Kubernetes)
# resource "aws_apigatewayv2_route" "pedidos_route" {
#   api_id    = aws_apigatewayv2_api.main_gateway.id
#   route_key = "ANY /pedidos/{proxy+}" # Pega qualquer coisa depois de /pedidos
#   target    = "integrations/${aws_apigatewayv2_integration.k8s_integration.id}"
# }

# # 6. A Integração (Aqui mora o "Pulo do Gato")
# resource "aws_apigatewayv2_integration" "k8s_integration" {
#   api_id           = aws_apigatewayv2_api.main_gateway.id
#   integration_type = "HTTP_PROXY"
  
#   # Conecta via VPC Link
#   connection_type      = "VPC_LINK"
#   connection_id        = aws_apigatewayv2_vpc_link.eks_link.id
  
#   # --- ATENÇÃO AQUI ---
#   # O integration_uri precisa do ARN do Load Balancer (NLB) que o Kubernetes criar.
#   # Como o Terraform roda ANTES do Kubernetes, você tem um problema de "ovo e galinha".
#   # Solução temporária: Coloque um valor placeholder ou use um Data Source se o LB já existir.
#   # O ideal é usar o ARN do listener do NLB.
  
#   integration_method   = "ANY"
#   integration_uri      = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/net/meu-nlb/..." 
# }