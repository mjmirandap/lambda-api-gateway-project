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

# --- GENERAR COMANDOS ---

output "cognito_user_pool_id" {
  description = "ID del Cognito User Pool"
  value       = aws_cognito_user_pool.pool.id
}

output "cognito_client_id" {
  description = "Client ID del Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.client.id
}

output "command_signup" {
  description = "Comando para registrar usuario en Cognito"
  value = <<-EOT
      aws cognito-idp sign-up \
      --client-id ${aws_cognito_user_pool_client.client.id} \
      --username <yourUserName> \
      --password '<strongPassword>' \
      --user-attributes Name=email,Value=<yourEMail@domain.com>

}

output "command_confirm" {
  description = "Comando para confirmar el usuario en Cognito"
  value = <<-EOT
    aws cognito-idp admin-confirm-sign-up \
      --user-pool-id ${aws_cognito_user_pool.pool.id} \
      --username <yourUserName>
  
}

output "command_authenticate" {
  description = "Comando para autenticarse y obtener tokens JWT"
  value = <<-EOT
    aws cognito-idp initiate-auth \
      --auth-flow USER_PASSWORD_AUTH \
      --client-id ${aws_cognito_user_pool_client.client.id} \
      --auth-parameters USERNAME=<yourUserName>,PASSWORD='<strongPassword>'
  
}

output "command_curl_api" {
  description = "Comando curl para llamar al API Gateway (reemplazar <IdToken>)"
  value = <<-EOT
    curl -X GET "${aws_apigatewayv2_api.api.api_endpoint}/" \
      -H "Authorization: Bearer <IdToken>"
   EOT
}