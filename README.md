# Overview

This simple Lambda function invokes OpenWeatherMap.org API to retrieve the current weather for a city.


# Architecture

This is what will be created:

![Diagram - PyWeather architecture](/diagrams/aws-pyweather-demo-arch.png)


A CI/CD Pipeline is created as well:

![Diagram - PyWeather CI/CD Pipeline](/diagrams/aws-pyweather-demo-pipeline.png)


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

## Create a CodeCommit repo

The CI/CD Pipeline assumes you are using CodeCommit (NOT GitHub)

Follow these steps to create a repo
```
aws codecommit create-repository --repository-name "PyWeather-Demo" --repository-description "TEMPORARY - Definitive version lives on GitHub"
```

Then, simply add that as a new remote , and push to it. 

```
git remote add codecommit (SSH or HTTPS here)
git push codecommit
```

If you run 
```
git remote -v
```

It should look like:
```
github  git@github.com:tplatt37/PyWeather-Demo.git (fetch)
github  git@github.com:tplatt37/PyWeather-Demo.git (push)
origin  ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos/PyWeather-Demo (fetch)
origin  ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos/PyWeather-Demo (push)
```


## Two Ways to Install

The best way to install is to run the CI/CD Pipeline script.  This will create the CI/CD pipeline, which will automatically run and deploy the function too!

```
./03-deploy-pipeline.sh 
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

## Uninstall

To uninstall: 

Run
```
./uninstall.sh
```

You should DELETE the PyWeather-Demo CodeCommit repository you created.

Finally, manually delete the SecretsManager secret (or leave it for next time)

## Requirements

You need SAM CLI installed 

You need Docker (for step-through debugging demos)

You need Python3.8 installed

You need jq installed
