resource "aws_apigatewayv2_api" "main_gateway" {
  name          = "tech-challenge-gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main_gateway.id
  name        = "$default"
  auto_deploy = true
}