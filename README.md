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
                "apigatewayv2:*",
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

