#
# NOTE: When using SAM, it's not possible to get the API Gateway
# trigger to show in the Console properly. There's a glaring red error message
# But, you can run this command to get rid of it!
# 
# Replace zzz with the Function name
# Replace xxx with the AccountId, and yyy with the Rest API Id
#

# Pull this info from the stack exports...
echo "This will fix the API GW Trigger Permissions issue that causes an error in the Lambda console UI"

# Retrieve CloudFormation Stack export named "PyWeatherDemoLambdaName"
LAMBDA_NAME=$(aws cloudformation describe-stacks \
--stack-name PyWeather-Demo \
--query 'Stacks[].Outputs[?OutputKey==`PyWeatherDemoLambdaName`].OutputValue' \
--output text)
echo "LAMBDA_NAME=$LAMBDA_NAME"

API=$(aws cloudformation describe-stacks \
--stack-name PyWeather-Demo \
--query 'Stacks[].Outputs[?OutputKey==`PyWeatherDemoRestApi`].OutputValue' \
--output text)
echo "API=$API"

ACCOUNT_ID=$(aws cloudformation describe-stacks \
--stack-name PyWeather-Demo \
--query 'Stacks[].Outputs[?OutputKey==`PyWeatherDemoAccountId`].OutputValue' \
--output text)
echo "ACCOUNT_ID=$ACCOUNT_ID"

aws lambda add-permission \
--function-name $LAMBDA_NAME \
--action lambda:InvokeFunction \
--statement-id test \
--principal apigateway.amazonaws.com \
--source-arn arn:aws:execute-api:us-west-2:$ACCOUNT_ID:$API/*/GET/weather