//
// This is NodeJS18.x with AWS SDK V3
// https://aws.amazon.com/blogs/compute/node-js-18-x-runtime-now-available-in-aws-lambda/
//

import { LambdaClient, InvokeCommand } from '@aws-sdk/client-lambda';
const lambda = new LambdaClient();

import { CodeDeployClient, PutLifecycleEventHookExecutionStatusCommand } from "@aws-sdk/client-codedeploy";
const codedeploy = new CodeDeployClient();

export const handler = async (event, context) => {

	//
	// This will invoke the Lambda (new version!) we just deployed and 
	// check for a 200 response code. It will then report back to CodeDeploy
	// If "Succeeded" the deployment will continue.
	// If "Failed" CodeDeploy will trigger a rollback.
	//
	// If you want to see that , try making a change to the Payload
	// such as changing "city" to "xxxcity" - that causes the lambda invocation to fail.
	//
	// For simplicity sake, this is the same code as the beforeAllowTraffic hook
	

	console.log("Entering afterAllowTraffic hook...");
	
	// Read the DeploymentId and LifecycleEventHookExecutionId from the event payload
	var deploymentId = event.DeploymentId;
	console.log("DeploymentId: " + deploymentId);

	var lifecycleEventHookExecutionId = event.LifecycleEventHookExecutionId;
	console.log("LifecycleEventHookExecutionId: " + lifecycleEventHookExecutionId);
	
	var functionToTest = process.env.NewVersion;
	console.log("Testing new function version: " + functionToTest);

	// Create parameters to pass to the updated Lambda function that
	// If you want to simulate a HOOK failure, you can change the Payload here to have something 
	// other than "city" which will cause the Lambda to fail.
	var lambdaParams = {
		FunctionName: functionToTest,    
		Payload: "{\"queryStringParameters\": {\"city\": \"Scranton\"}}",  
		InvocationType: "RequestResponse"
	};
	
	const command = new InvokeCommand(lambdaParams);
	
	var lambdaResult = "Failed";
	// Invoke the updated Lambda function.
	// We simply make sure the Lambda works.  A more robust implementation
	// would check the response in detail.
	const response = await lambda.send(command)

	console.log("Response from function invocation: ");
	// https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/clients/client-lambda/interfaces/invokecommandoutput.html
	console.log(response);

	// Require a 200 response code for success, otherwise it failed in some way.
	if (response.StatusCode == "200"){
		console.log("Validation succeeded");
		
		var result = response.Payload.transformToString();
		console.log("Payload: " +  result);

		lambdaResult = "Succeeded";
	}
	else {
		console.log("Validation failed");
		lambdaResult = "Failed";
	}

	// Complete the PreTraffic Hook by sending CodeDeploy the validation status
	var codeDeployParams = {
		deploymentId: deploymentId,
		lifecycleEventHookExecutionId: lifecycleEventHookExecutionId,
		status: lambdaResult // status can be 'Succeeded' or 'Failed'
	};
	
	const statuscommand = new PutLifecycleEventHookExecutionStatusCommand(codeDeployParams);

	const codeDeployResponse = await codedeploy.send(statuscommand);
	console.log(codeDeployResponse.lifecycleEventHookExecutionId)	

}