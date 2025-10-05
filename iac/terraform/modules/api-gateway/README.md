API Gateway (REST) module

Creates a REST API with:
- Proxy integration to OpenWeather API endpoint
- Automatic API key injection for OpenWeather API authentication
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
  endpoint_domain        = "api.openweathermap.org"
  endpoint_port          = 443
  endpoint_protocol      = "https"
  lambda_authorizer_arn  = module.lambda_authorizer.arn
  openweather_api_key    = var.openweather_api_key
  stage_names            = ["staging", "production"]
  tags = {
    Environment = var.environment
    Project     = "max-weather"
  }
}
```

**Important Security Note:**
The `openweather_api_key` variable is marked as sensitive to prevent it from being displayed in logs or state files. Make sure to set this variable in your terraform.tfvars files with your actual OpenWeather API key.

