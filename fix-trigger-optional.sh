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

REGION="us-east-1"

LAMBDA_NAME=$(aws cloudformation list-exports --query "Exports[?Name=='PyWeatherDemoLambdaName'].Value" --output text)
echo "LAMBDA_NAME=$LAMBDA_NAME"

APIGW=$(aws cloudformation list-exports --query "Exports[?Name=='PyWeatherDemoRestApi'].Value" --output text)
echo "APIGW=$APIGW"

ACCOUNT_ID=$(aws cloudformation list-exports --query "Exports[?Name=='PyWeatherDemoAccountId'].Value" --output text)
echo "ACCOUNT_ID=$ACCOUNT_ID"

#
# Instead of this:
#arn:aws:execute-api:us-east-1:753157545766:gkhampsmjg/*/GET/weather
#
# We need:
# arn:aws:execute-api:us-east-1:753157545766:b18b8ga800/*/*/PyWeather-Demo-PyWeatherDemo-vZg0DUIEhUKx

aws lambda add-permission \
--function-name $LAMBDA_NAME \
--action lambda:InvokeFunction \
--statement-id "apigw-fixed-$APIGW" \
--principal apigateway.amazonaws.com \
--source-arn arn:aws:execute-api:$REGION:$ACCOUNT_ID:$APIGW/*/*/$LAMBDA_NAME