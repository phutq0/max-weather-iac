project_name              = "max-weather"
region                    = "us-east-1"
vpc_cidr                  = "10.0.0.0/16"
enable_nat_gateway        = true
eks_cluster_version       = "1.28"
node_instance_types       = ["t3.medium"]
api_gateway_stage_name    = "staging"
cloudwatch_retention_days = 7

# OpenWeather API Configuration
openweather_api_key = "your-openweather-api-key-here"

