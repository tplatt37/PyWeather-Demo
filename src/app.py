import sys
import os
import boto3
import requests
import json
import time

def lambda_handler(event, context):
    
    print(event)
    
    print("Lambda function ARN:", context.invoked_function_arn)
    print("Lambda function Version:", context.function_version)
    print("Lambda function memory limits in MB:", context.memory_limit_in_mb)
    
    location = event['queryStringParameters']['city']
    
    print("Retrieving weather for city = " + location)
    
    # Add sleep here to demo concurrent executions easily
    #time.sleep(5)
    
    weather = get_weather(API_KEY, location)
 
    print(weather['main']['temp'])
    print(weather)  
    
    #Add something to the output we can use to demonstrate code changes
    weather['PyWeatherVersion'] = "1.0.0"
    
    print("Lambda time remaining in MS:", context.get_remaining_time_in_millis())
    
    # This is compatible with Lambda Proxy Integration - this is the expected response format:
    return {
       "statusCode": 200,
       "isBase64Encoded": False,
       "headers": {
          "Content-Type": "application/json"
        },
        "body": json.dumps(weather)
    }

def get_weather(api_key, location):
    url = "https://api.openweathermap.org/data/2.5/weather?q={}&units=metric&appid={}".format(location, api_key)
    r = requests.get(url)
    
    return r.json()

def get_secret():

    secret_name = "openweather-api-key"
    secret = ""

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager'
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e
    else:
        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
        secret = json.loads(get_secret_value_response['SecretString'])
        
    return secret['apikey']

# Initialize API Key outside of Handler for efficiency
# API_KEY is a global variable that will hold the API Key
# On a COLD START this code will be executed.
# On a WARM START this variable will already be populated.
API_KEY = get_secret()
