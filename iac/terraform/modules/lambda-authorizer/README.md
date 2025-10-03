Lambda Authorizer (Node.js) module

Implements JWT validation, optional token introspection, and 5m cache.

Example usage:

```hcl
module "lambda_authorizer" {
  source = "./terraform/modules/lambda-authorizer"
  name   = "weather-auth"
  region = var.region

  env = {
    OAUTH_ISSUER              = "https://issuer.example.com"
    OAUTH_AUDIENCE            = "api://weather"
    OAUTH_INTROSPECTION_URL   = "https://issuer.example.com/oauth/introspect"
    OAUTH_CLIENT_ID           = "client-id"
    OAUTH_CLIENT_SECRET       = "client-secret"
    CACHE_TTL_SECONDS         = "300"
  }
}
```

