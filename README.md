# Overview

This simple Lambda function invokes OpenWeatherMap.org API to retrieve the current weather for a city.

It is created via a CI/CD Pipeline, and can be used to demonstrate advanced concepts like CodeDeploy traffic shifting deployments and SAM CLI step through debugging.

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

# Installation

First, you must request an API Key from OpenWeatherMap.org, for the "Current Weather Data" API.

## Register on OpenWeather Map.org

https://openweathermap.org/api

Request an API key.  

## Create a Secret in Secrets Manager

We'll store the OpenWeatherMap API key in Secrets manager.

First, you'll need to create the Secret (replace YOUR_API_KEY_HERE with yours!)

```
aws secretsmanager create-secret --name "openweather-api-key" --secret-string '{"apikey":"YOUR_API_KEY_HERE"}' --region us-west-2

SECRETARN=$(aws secretsmanager describe-secret --secret-id openweather-api-key --region us-west-2 | jq -r '.ARN')

echo $SECRETARN
```

Any region can be used, but us-west-2 is shown in the example commands.

## Specify an S3 bucket to use for the sam build command

We just need any S3 bucket where any the code can be packaged via sam package command. This bucket is also used to temporarily stage a zip of the full source code.

Replace YOUR_BUCKET_NAME with the name of a bucket in the same region as where you wish to deploy.

```
BUCKETNAME=YOUR_BUCKET_NAME

echo $BUCKETNAME
```


## Two Ways to Install

The best way to install is to run the CI/CD Pipeline installation script.  This will create the CI/CD pipeline, which will automatically run and deploy the function too!
You must provide the name of an S3 bucket that can be used to stage the ZIP of source code (to initialize the CodeCommit repo)

```
export AWS_DEFAULT_REGION=us-west-2
./install.sh "BUCKET_NAME"
```

NOTE that the CodeBuild project's buildspec will dynamically find the Secret given the name is static.


Or you can install the Lambda function itself first.

```
export AWS_DEFAULT_REGION=us-west-2
./01-build.sh $BUCKETNAME
./02-deploy.sh $BUCKETNAME $SECRETARN
```

You should see any error messages on the output, or in the CloudFormation stack.

This will create the basic Lambda function, which you can then execute in the console for demonstrations (or via API Gateway endpoint)

## NOTE about the CI/CD Pipeline

The "install.sh" script uses a ZIP file to create a CodeCommit repo with the application source code.

The CI/CD Pipeline is triggered by commits to the CodeCommit repo. It is NOT triggered from the GitHub repo.

The CodeCommit repo will be named : PyWeather-Demo

## NOTE about the API Gateway

If you click the "Trigger" button for API Gateway you'll see an error message in red.  Please ignore it, the API GW invocation URL will be fully functional.   This seems to be a SAM CLI side effect and not quite sure how to fix.

# Invoking the Lambda

An API Gateway REST API is available.

Find the API Endpoint from the Stack outputs, and add a querystring parameter on the end, such as the following, and simply open it in your browser (That's a GET request!)

```
https://gkhexample.execute-api.us-west-2.amazonaws.com/Prod/weather?city=Orlando
```

You can also find the invoke URL by navigating through the Trigger button in Lambda console. Please note an error (in scary red!) will be displayed, just ignore that. It's a SAM CLI issue that doesn't impact anything.

## To Demo the 80/20 Canary

A custom DeploymentConfiguration (CodeDeploy) is used to deploy new versions of the lambda using the "Canary" technique.

0. Clone down the CODECOMMIT repo. Use https or ssh or GRC - any way you can clone and then commit/push will work.
1. Make a change to the app.py source code - change the Version number 1.0.0 (So it's visible via GET call)
2. You MUST push to CodeCommit - that's what triggers the pipline.
```
git commit -am "update" && git push codecommit
```
3. Watch CodeDeploy for the deployment.
4. Use the REST API in API Gateway, which is utilizing the ":live" alias.  Trigger the Lambda repeatedly and you'll see the invocations are split 80%/20% accross the old and new versions. 

## To Demo REST API Caching

REST API in API Gateway has numerous features (that HTTP API does not).

To demo caching:
1. Go to the API Gateway REST API
2. Enable caching for the Stage.
3. Go to the METHOD REQUEST of the /weather GET method and add "city" as a querystring parameter. Make sure the "Caching" option is checked (for per-query string caching!)
4. Deploy the API

Then, bring up the weather for a new city. 
(Then again, and again, and again)

You can tell it is cached if:
* CloudWatch Logs for the Lambda should show only 1 invocation
* The Time (in Firefox Developer Tools) should be 1/2 second shorter for each subsequent GET
* DO NOT look at the x-cache header, that IS NOT RELEVANT as per the docs

[Enabling API caching to enhance responsiveness](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-caching.html)

## Uninstall

To uninstall: 

Run
```
export AWS_DEFAULT_REGION=us-west-2
./uninstall.sh
```

Finally, manually delete the SecretsManager secret (or leave it for next time)

