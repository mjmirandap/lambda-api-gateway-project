provider "aws" {
  region = "us-east-2" 
}


data "aws_region" "current" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# IAM Role para Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role-${random_string.suffix.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Compresion de Codigo
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "src/lambda_handler.py"
  output_path = "lambda_handler.zip"
}

# Creación de la función Lambda 
resource "aws_lambda_function" "greeting_lambda" {
  function_name    = "greeting-lambda-${random_string.suffix.result}"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "lambda_handler.handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      GREETING_MESSAGE = "Hola, tu despliegue de IaC fue exitoso!" 
    }
  }
}

# Cognito 
resource "aws_cognito_user_pool" "pool" {
  name = "app-pool-${random_string.suffix.result}"
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "api-client"
  user_pool_id = aws_cognito_user_pool.pool.id
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

# API Gateway 
resource "aws_apigatewayv2_api" "api" {
  name          = "http-greeting-api-${random_string.suffix.result}"
  protocol_type = "HTTP"
}

# Authorizer Cognito
resource "aws_apigatewayv2_authorizer" "authorizer" {
  api_id = aws_apigatewayv2_api.api.id
  authorizer_type = "JWT"
  name = "CognitoAuthorizer"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.client.id]
    issuer = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.pool.id}"
  }
}

# Integracion de cognito con Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.greeting_lambda.invoke_arn
  integration_method = "POST"
}

# Ruta get y estado
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type   = "JWT" 
  authorizer_id        = aws_apigatewayv2_authorizer.authorizer.id
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

# Permiso para invocar la lambda desde API gw
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.greeting_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}