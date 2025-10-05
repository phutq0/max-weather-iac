provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

locals {
  name = "${var.project_name}-${var.environment}"
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "vpc" {
  source = "./modules/vpc"

  name                 = local.name
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = [for i in range(3) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs = [for i in range(3, 6) : cidrsubnet(var.vpc_cidr, 8, i)]
  tags                 = local.tags
}

module "iam" {
  source = "./modules/iam"
  
  cluster_name              = local.name
  region                    = var.region
  oidc_issuer_url          = module.eks.cluster_oidc_issuer
  permission_boundary_arn  = var.permission_boundary_arn
  enable_external_dns      = var.enable_external_dns
  enable_karpenter         = var.enable_karpenter
  karpenter_service_account = var.karpenter_service_account
  app_service_account      = var.app_service_account
  app_s3_bucket_arns       = var.app_s3_bucket_arns
  app_dynamodb_table_arns  = var.app_dynamodb_table_arns
  tags                     = local.tags
}

module "eks" {
  source                  = "./modules/eks"
  name                    = local.name
  region                  = var.region
  cluster_version         = var.eks_cluster_version
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  enable_ebs_csi_driver   = var.enable_ebs_csi_driver
  
  # Node Group Configuration
  enable_spot_node_group   = var.enable_spot_node_group
  enable_ondemand_node_group = var.enable_ondemand_node_group
  
  # Spot Node Group Settings
  spot_node_instance_types = var.spot_node_instance_types
  spot_node_min_size      = var.spot_node_min_size
  spot_node_max_size      = var.spot_node_max_size
  spot_node_desired_size  = var.spot_node_desired_size
  
  # On-Demand Node Group Settings
  ondemand_node_instance_types = var.ondemand_node_instance_types
  ondemand_node_min_size      = var.ondemand_node_min_size
  ondemand_node_max_size      = var.ondemand_node_max_size
  ondemand_node_desired_size  = var.ondemand_node_desired_size
  
  # EKS access entries
  access_entries = var.eks_access_entries

  # Optional legacy aws-auth mappings
  aws_auth_map_users = var.aws_auth_map_users
  aws_auth_map_roles = var.aws_auth_map_roles

  tags = local.tags
}

module "cloudwatch" {
  source                  = "./modules/cloudwatch"
  region                  = var.region
  environment             = var.environment
  cluster_name            = module.eks.cluster_name
  oidc_provider_arn       = module.eks.cluster_oidc_provider_arn
  oidc_provider_url       = module.eks.cluster_oidc_issuer
  sns_email_subscriptions = []
  tags                    = local.tags
}

module "lambda_authorizer" {
  source = "./modules/lambda-authorizer"
  name   = "${local.name}-authorizer"
  region = var.region
  api_gateway_execution_arn = module.api_gateway.execution_arn
  env = {
    OAUTH_ISSUER            = "https://issuer.example.com"
    OAUTH_AUDIENCE          = "api://weather"
    OAUTH_INTROSPECTION_URL = "https://issuer.example.com/oauth/introspect"
    OAUTH_CLIENT_ID         = "REPLACE"
    OAUTH_CLIENT_SECRET     = "REPLACE"
    VERSION                 = "2.0.0"
    OPENWEATHER_API_KEY     = var.openweather_api_key
  }
  tags = local.tags
}

module "api_gateway" {
  source                = "./modules/api-gateway"
  name                  = "${local.name}-api"
  region                = var.region
  endpoint_uri          = "api.openweathermap.org/data/2.5" # Call directly to OpenWeather API for testing
  endpoint_protocol     = "https"
  lambda_authorizer_arn = module.lambda_authorizer.lambda_arn
  stage_names           = [var.api_gateway_stage_name]
  openweather_api_key   = var.openweather_api_key
  tags                  = local.tags
}

# ECR Repository for Dev Environment

module "ecr" {
  source = "./modules/ecr"
  
  repository_names = var.ecr_repository_names
  
  # Dev environment settings
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push        = var.ecr_scan_on_push
  encryption_type     = var.ecr_encryption_type
  
  # Aggressive cleanup for dev environment
  enable_lifecycle_policy = var.ecr_enable_lifecycle_policy
  max_image_count        = var.ecr_max_image_count
  max_image_age_days     = var.ecr_max_image_age_days
  
  tags = local.tags
}




output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster endpoint"
}

output "api_gateway_urls" {
  value       = module.api_gateway.stage_invoke_urls
  description = "API Gateway stage invoke URLs"
}

# ECR Outputs
output "ecr_repository_url" {
  value       = module.ecr.repository_urls["max-weather-dev"]
  description = "ECR repository URL for max-weather-dev"
}

output "ecr_repository_uri" {
  value       = module.ecr.repository_uris["max-weather-dev"]
  description = "Full ECR repository URI for Docker commands"
}


