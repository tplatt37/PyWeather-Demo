# Overview

This simple Lambda function invokes OpenWeatherMap.org API to retrieve the current weather for a city.


# Architecture

This is what will be created:

![Diagram - PyWeather architecture](/diagrams/aws-pyweather-demo-arch.png)


A CI/CD Pipeline is created as well:

![Diagram - PyWeather CI/CD Pipeline](/diagrams/aws-pyweather-demo-pipeline.png)

# Pre-requisites

To use this - you need:
1) a Private S3 bucket to use as a place to stage the source code (for creating a CodeCommit repo)
2) Python3.11 - if you want to build and deploy locally
3) jq must be installed
4) Docker - (if showing step-through debugging with SAM CLI)
5) SAM CLI
6) You must have Git Remote CodeCommit (GRC) enabled.

# Installation

First, you must request an API Key from OpenWeatherMap.org, for the "Current Weather Data" API.

## Register on OpenWeather Map.org

https://openweathermap.org/api

Request an API key.  

## Create a Secret in Secrets Manager

We'll store the OpenWeatherMap API key in Secrets manager.

First, you'll need to create the Secret (replace YOUR_API_KEY_HERE with yours!)

```
aws secretsmanager create-secret --name "openweather-api-key" --secret-string '{"apikey":"YOUR_API_KEY_HERE"}'

SECRETARN=$(aws secretsmanager describe-secret --secret-id openweather-api-key | jq -r '.ARN')

echo $SECRETARN
```

## Specify an S3 bucket to use for the sam build command

We just need any S3 bucket where any the code can be packaged via sam package command.

Replace YOUR_BUCKET_NAME with the name of a bucket in the same region as where you wish to deploy.

```
BUCKETNAME=YOUR_BUCKET_NAME

echo $BUCKETNAME
```


## Two Ways to Install

The best way to install is to run the CI/CD Pipeline script.  This will create the CI/CD pipeline, which will automatically run and deploy the function too!
You must provide the name of an S3 bucket that can be used to stage the ZIP of source code (to initialize the CodeCommit repo)

```
./install.sh "BUCKET_NAME"
```

NOTE that the CodeBuild project's buildspec will dynamically find the Secret given the name is static.


Or you can install the Lambda function itself first.

```
./01-build.sh $BUCKETNAME
./02-deploy.sh $BUCKETNAME $SECRETARN
```

You should see any error messages on the output, or in the CloudFormation stack.

This will create the basic Lambda function, which you can then execute in the console for demonstrations (or via API Gateway endpoint)

## Install CI/CD Pipeline

This will create a CI/CD Pipeline that you can use for DevOps demos.

This CI/CD Pipeline will peacefully co-exist with manually deploying as described above.

The pipeline subfolder contains a CF template for a CodePipeline/CodeBuild/CloudFormation CI/CD pipeline.

```
./03-deploy-pipeline.sh 
```

NOTE: The pipeline assumes you are using AWS CodeCommit - NOT GITHUB!

## NOTE about the API Gateway

It will NOT show up on the Lambda Trigger page, but it's there - go look in API Gateway console.
The API is a REST API named "PyWeather-Demo"

## To Demo the 50/50 Canary

1. Make a change to the app.py source code - change the Version number 1.0.0 (So it's visible via GET call)
2. You MUST push to CodeCommit 
```
git commit -am "update" && git push codecommit
```
3. Watch CodeDeploy for the deployment.
4. Use the REST API in API Gateway, which is utilizing the ":live" alias.   

Don't try to use a manually created API - it must be pointed to :live alias.



## Uninstall

To uninstall: 

Run
```
./uninstall.sh
```

You should DELETE the PyWeather-Demo CodeCommit repository you created.

Finally, manually delete the SecretsManager secret (or leave it for next time)

