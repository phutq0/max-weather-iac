exports.handler = async (event) => {
  console.log('🔵 Lambda authorizer invoked');
  console.log('Event:', JSON.stringify(event, null, 2));
  
  try {
    const token = (event.authorizationToken || '').replace(/^Bearer\s+/i, '');
    
    if (!token) {
      console.log('❌ No token provided');
      return {
        principalId: 'anonymous',
        policyDocument: {
          Version: '2012-10-17',
          Statement: [{
            Action: 'execute-api:Invoke',
            Effect: 'Deny',
            Resource: event.methodArn
          }]
        }
      };
    }

    console.log('✅ Token received:', token.substring(0, 10) + '...');
    
    // Build wildcard resource ARN
    const tmp = event.methodArn.split(':');
    const apiGatewayArnTmp = tmp[5].split('/');
    const wildcardResource = `arn:aws:execute-api:${tmp[3]}:${tmp[4]}:${apiGatewayArnTmp[0]}/${apiGatewayArnTmp[1]}/*/*`;
    
    console.log('✅ Generated resource:', wildcardResource);
    
    const policy = {
      principalId: 'test-user',
      policyDocument: {
        Version: '2012-10-17',
        Statement: [{
          Action: 'execute-api:Invoke',
          Effect: 'Allow',  // ← Make sure this is 'Allow'
          Resource: wildcardResource
        }]
      },
      context: {
        sub: 'test-user',
        scope: 'read:weather'
      }
    };
    
    console.log('✅ Returning policy:', JSON.stringify(policy, null, 2));
    return policy;
    
  } catch (err) {
    console.error('❌ Auth error:', err);
    return {
      principalId: 'error',
      policyDocument: {
        Version: '2012-10-17',
        Statement: [{
          Action: 'execute-api:Invoke',
          Effect: 'Deny',
          Resource: event.methodArn
        }]
      }
    };
  }
};