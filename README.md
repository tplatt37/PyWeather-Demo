# Overview

# Installation

## Register on OpenWeather Map.org

https://openweathermap.org/api

## Create a Secret in Secrets Manager

We'll store the OpenWeatherMap API key in Secrets manager.

First, you'll need to create it (replace YOUR_API_KEY_HERE with yours!)

aws secretsmanager create-secret --name "openweather-api-key" --secret-string '{"apikey":"YOUR_API_KEY_HERE"}'

SECRETARN=$(aws secretsmanager describe-secret --secret-id openweather-api-key | jq -r '.ARN')
echo $SECRETARN

## Specify an S3 bucket to use for the sam build command

We just need any S3 bucket where any the code can be packaged via sam package command.

Replace YOUR_BUCKET_NAME with the name of a bucket in the same region as where you wish to deploy.

BUCKETNAME=YOUR_BUCKET_NAME
echo $BUCKETNAME

## Install via SAM

./01-build.sh $BUCKETNAME

./02-deploy.sh $BUCKETNAME $SECRETARN

You should see any error messages on the output, or in the CloudFormation stack.

This will create the basic Lambda function, which you can then execute in the console for demonstrations.

## Install CI/CD Pipeline

This will create a CI/CD Pipeline that you can use for DevOps demos.

This CI/CD Pipeline will peacefully co-exist with manually deploying as described above.

The pipeline subfolder contains a CF template for a CodePipeline/CodeBuild/CloudFormation CI/CD pipeline.

./03-deploy-pipeline.sh 

## Uninstall

Simply delete both Cloudformation stacks.
Then, manually delete the SecretsManager secret.

## Requirements

You need SAM CLI installed 
You need Docker (for step-through debugging demos)
You need Python3.8 installed
You need jq installed
