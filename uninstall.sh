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
if [[ "$UTILITY_BUCKET" != "" ]]; then
  echo "Will empty bucket $UTILITY_BUCKET - to prevent stack delete from failing..."
  aws s3 rm s3://$UTILITY_BUCKET --recursive
fi

# Delete this stack first!
# But make sure it's not in UPDATE_IN_PROGRESS, because that causes issues.. (it can't be deleted)
STACK_NAME=$PREFIX

# Check if stack is in UPDATE_IN_PROGRES
STACK_STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].StackStatus" --output text)
if [ "$STACK_STATUS" == "UPDATE_IN_PROGRESS" ]; then
  echo "Stack ($STACK_NAME) is in UPDATE_IN_PROGRESS, cannot delete it yet. Please wait for it to finish and try again"
  exit 1
fi

echo "Deleting ($STACK_NAME) ..."
aws cloudformation delete-stack --stack-name $STACK_NAME
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME 

STACK_NAME=$PREFIX-Pipeline
echo "Deleting ($STACK_NAME) ..."
aws cloudformation delete-stack --stack-name $STACK_NAME
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME 

STACK_NAME=$PREFIX-repo
echo "Deleting ($STACK_NAME) ..."
aws cloudformation delete-stack --stack-name $STACK_NAME
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME 
