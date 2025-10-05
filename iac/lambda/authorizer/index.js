exports.handler = async (event) => {
  console.log('🔵 Lambda authorizer invoked');
  console.log('Event:', JSON.stringify(event, null, 2));

  const token = (event.authorizationToken || event.identitySource?.[0] || '').replace(/^Bearer\s+/i, '');

  if (!token) {
    console.log('❌ No token provided');
    return deny(event.methodArn || event.routeArn);
  }

  console.log('✅ Token received:', token);

  // 🔒 Retrieve the OpenWeather API key from environment variable
  const openWeatherApiKey = process.env.OPENWEATHER_API_KEY;
  if (!openWeatherApiKey) {
    console.error('❌ Missing OPENWEATHER_API_KEY environment variable');
    throw new Error('Server configuration error');
  }

  // ✅ Construct IAM policy and inject context
  const resource = event.methodArn || event.routeArn;
  const policy = {
    principalId: 'test-user',
    policyDocument: {
      Version: '2012-10-17',
      Statement: [{
        Action: 'execute-api:Invoke',
        Effect: 'Allow',
        Resource: resource
      }]
    },
    context: {
      sub: 'test-user',
      scope: 'read:weather',
      appid: openWeatherApiKey // 🧩 this gets passed securely to integration mapping
    }
  };

  console.log('✅ Returning policy:', JSON.stringify(policy, null, 2));
  return policy;
};

function deny(resource) {
  return {
    principalId: 'anonymous',
    policyDocument: {
      Version: '2012-10-17',
      Statement: [{
        Action: 'execute-api:Invoke',
        Effect: 'Deny',
        Resource: resource
      }]
    }
  };
}
