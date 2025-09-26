# Políticas

## 1\. Política de Gestión del Stack (Lambda, API Gateway, Logs)

Esta política otorga permisos para crear los recursos de la aplicación *serverless* (Lambda y API Gateway) y los servicios de monitoreo (**CloudWatch Logs**) y autenticación (**Cognito**).

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ManageApplicationResources",
            "Effect": "Allow",
            "Action": [
                "lambda:*",
                "apigateway:*",
                "cognito-idp:*",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
```

-----

## 2\. Política de Gestión de Identidad (IAM Lifecycle y PassRole)

Esta es la política crítica que permite a Terraform crear los roles de ejecución de Lambda y, lo que es más importante, pasarlos a los servicios de AWS.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ManageIAMRoles",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:GetRole",
                "iam:ListRolePolicies",
                "iam:PassRole"
            ],
            "Resource": "*"
        }
    ]
}
```

-----
## 3\. Otras políticas de AWS 

⚠️Solo son recomendables activar en caso que presente fallas

``` bash
📦AmazonEC2ContainerRegistryFullAccess
📦AmazonEC2FullAccess
📦AmazonECS_FullAccess
```

# Outputs
## 1. Variables de salida
``` shell
URL del API Gateway = api_gateway_url
ARN de la Lambda = lambda_arn 
ID del autorizador Cognito = cognito_authorizer_id 

#Extras
cognito_user_pool_id
cognito_client_id

#Adicionalmente, comandos para replicar consumo autenticado


```

## 2. Comandos

Para la ejecución de los comandos en la terminal, use la siguiente sintaxis:

* **Valores de Terraform (Output):** La información encerrada en **corchetes `[]`** es generada automáticamente al ejecutar `$ terraform apply`. 
* **Valores de l usuario:** La información encerrada en **signos `< >`** debe ser ingresada manualmente por usted (ej. su usuario, contraseña y correo).
``` shell


#Ejecutar en este orden

#1. Registrar usuario (command_signup)
aws cognito-idp sign-up \
--client-id [cognito_client_id] \
--username <yourUserName> \
--password '<strongPassword>' \
--user-attributes Name=email,Value=<yourEMail@domain.com>

#2. Confirmar usuario registrado (command_confirm)
aws cognito-idp admin-confirm-sign-up \
  --user-pool-id [cognito_user_pool_id] \
  --username <yourUserName>


#3. Autenticar (command_authenticate)
aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id [cognito_client_id] \
  --auth-parameters USERNAME=<yourUserName>,PASSWORD='<strongPassword>' 
  #Si PASSWORD coma (,) escapar con backslash (\)
      
#4. (Opcional)
# CURL (command_curl_api), puede ser montado en Postman
curl -X GET "<api_gateway_url>" \
  -H "Authorization: Bearer <IdToken>"


```

