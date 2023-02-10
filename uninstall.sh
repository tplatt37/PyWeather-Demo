#!/bin/bash

#
# This uninstalls (DELETES!) everything.
# No snapshots, nothing is retained.
#
PREFIX=PyWeather-Demo

REGION=${AWS_DEFAULT_REGION:-$(aws configure get default.region)}


# Get the artifacts bucket from the Pipeline stack
UTILITY_BUCKET=$(aws cloudformation list-exports --query "Exports[?Name=='$PREFIX-ArtifactStoreBucket'].Value" --output text)

# Empty the utility bucket (Otherwise stack delete will fail)
echo "Will empty bucket $UTILITY_BUCKET - to prevent stack delete from failing..."
aws s3 rm s3://$UTILITY_BUCKET --recursive


# Delete this stack first!
STACK_NAME=$PREFIX
echo "Deleting ($STACK_NAME) ..."
aws cloudformation delete-stack --stack-name $STACK_NAME
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME 


STACK_NAME=$PREFIX-Pipeline
echo "Deleting ($STACK_NAME) ..."
aws cloudformation delete-stack --stack-name $STACK_NAME
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME 

