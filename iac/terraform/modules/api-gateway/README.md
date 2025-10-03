API Gateway (REST) module

Creates a REST API with:
- Proxy integration to LB endpoint
- Stages (staging, production)
- Usage plan with API key and throttling (1000 rps)
- Lambda token authorizer for OAuth2 validation
- CORS and basic request/response models
- CloudWatch logging enabled

Example usage:

```hcl
module "api_gw" {
  source                 = "./terraform/modules/api-gateway"
  name                   = "weather-api"
  region                 = var.region
  endpoint_domain        = "lb.example.com"
  endpoint_port          = 443
  endpoint_protocol      = "https"
  lambda_authorizer_arn  = module.lambda_authorizer.arn
  stage_names            = ["staging", "production"]
  tags = {
    Environment = var.environment
    Project     = "max-weather"
  }
}
```

