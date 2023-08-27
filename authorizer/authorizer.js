exports.handler = async (event, contect) => {
    const expectedIP = '108.64.167.147'

    try {
        console.log(event);
        
        const forwardedForHeader = event.headers['X-Forwarded-For']
        const clientIP = forwardedForHeader.split(',')[0]

        console.log(`Client IP: ${clientIP}`)

        if (clientIP != expectedIP) {

            const policy = generatePolicy('user', 'Deny', event.methodArn);
            return policy;
        }
        else {
            const policy = generatePolicy('user', 'Allow', event.methodArn);
            return policy;
        }
    } catch(error)
    {
        console.error('Error:', error);
        const policy = generatePolicy('user', 'Deny', event.methodArn);
        return policy;
    
    }
}

// Function to generate an IAM Policy
const generatePolicy = (principalId, effect, resource) => {
    const authResponse = {};

    authResponse.principalId = principalId;
    if (effect && resource) {
        const policyDocument = {};
        policyDocument.Version = '2012-10-17';
        policyDocument.Statement = [];
        const statementOne = {};
        statementOne.Action = 'execute-api:Invoke';
        statementOne.Effect = effect;
        statementOne.Resource = resource;
        policyDocument.Statement[0] = statementOne;
        authResponse.policyDocument = policyDocument;
    }

    return authResponse;
}    
