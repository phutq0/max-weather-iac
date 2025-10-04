region = "ap-southeast-2"
project_name              = "max-weather"
vpc_cidr                  = "10.0.0.0/16"
enable_nat_gateway        = true
eks_cluster_version       = "1.32"
node_instance_types       = ["t3.medium"]
api_gateway_stage_name    = "dev"
cloudwatch_retention_days = 7
