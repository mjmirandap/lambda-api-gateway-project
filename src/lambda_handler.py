import os
import json

def handler(event, context):
    """Lee la variable de entorno y devuelve la respuesta."""
    
    # Intenta obtener el valor de la variable GREETING_MESSAGE
    message = os.environ.get('GREETING_MESSAGE', 'GREETING_MESSAGE no encontrada.')
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'message': message,
            'source': 'Python Lambda 3.11'
        })
    }