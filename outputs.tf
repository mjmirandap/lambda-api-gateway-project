output "api_gateway_url" {
  description = "URL publica para acceder al API Gateway"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "lambda_arn" {
  description = "ARN de la funcion Lambda desplegada"
  value       = aws_lambda_function.greeting_lambda.arn
}

output "cognito_authorizer_id" {
  description = "ID del Authorizer Cognito creado"
  value       = aws_apigatewayv2_authorizer.authorizer.id
}