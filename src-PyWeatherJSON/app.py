#
# This version only returns pure JSON and isn't compatible with API GW
# See notes below
# It's used for the Step Functions "bespoke" state machine demo
#
#

import sys
import os
import boto3
import logging
import requests
import json
import jsonpickle

print("COLDSTART: Initializing...")

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    
    logger.info('## EVENT\r' + jsonpickle.encode(event))
    logger.info('## CONTEXT\r' + jsonpickle.encode(context))
    
    print("Lambda function ARN:", context.invoked_function_arn)
    print("Lambda function Version:", context.function_version)
    print("Lambda function memory limits in MB:", context.memory_limit_in_mb)
    print("Lambda time remaining in MS:", context.get_remaining_time_in_millis())
    
    location = event['queryStringParameters']['city']
    
    print(location)
    weather = get_weather(API_KEY, location)
 
    print(weather['main']['temp'])
    print(weather)  
    weather['PyWeatherFunctionVersion'] = context.function_version
    
    # This version returns PURE JSON - which is easier to handle in Step Functions State Machine
    # This version isn't compatible with API Gateway Proxy Integration
    # If you need to debug do this:
    #
    #return json.loads("{\"feelslike\": 24}") #weather
    #
    #
    return json.loads("{\"feels_like\": " + str(weather['main']['feels_like'])  + ", \"city\": \"" + str(weather['name']) +"\"}")
    
    
def get_weather(api_key, location):
    url = "https://api.openweathermap.org/data/2.5/weather?q={}&units=metric&appid={}".format(location, api_key)
    r = requests.get(url)
    
    return r.json()

def get_secret():

    secret_name = "openweather-api-key"
    region_name = "us-west-2"
    secret = ""

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
    # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    # We rethrow the exception by default.

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

API_KEY = get_secret()
