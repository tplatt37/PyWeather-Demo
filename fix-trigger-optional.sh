#
# NOTE: When using SAM, it's not possible to get the API Gateway
# trigger to show in the Console properly.
# But, you can run this command
# 
# Replace zzz with the Function name
# Replace xxx with the AccountId, and yyy with the Rest API Id
#

# Pull this info from the stack exports...


aws lambda add-permission \
--function-name zzzzz \
--action lambda:InvokeFunction \
--statement-id test \
--principal apigateway.amazonaws.com \
--source-arn arn:aws:execute-api:us-west-2:xxx:yyyyy/*/GET/weather