project_name              = "max-weather"
region                    = "us-east-1"
vpc_cidr                  = "10.0.0.0/16"
enable_nat_gateway        = true
eks_cluster_version       = "1.29"
node_instance_types       = ["m5.large"]
api_gateway_stage_name    = "production"
cloudwatch_retention_days = 30

# OpenWeather API Configuration
openweather_api_key = "your-openweather-api-key-here"

# EKS Access Configuration
# Native EKS access entries (recommended)
eks_access_entries = []

# Optional legacy aws-auth mappings
aws_auth_map_users = []
aws_auth_map_roles = []

