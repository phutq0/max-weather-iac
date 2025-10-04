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

module "eks" {
  source                  = "./modules/eks"
  name                    = local.name
  region                  = var.region
  cluster_version         = var.eks_cluster_version
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  node_instance_types     = var.node_instance_types
  node_group_min_size     = var.min_node_count
  node_group_max_size     = var.max_node_count
  node_group_desired_size = var.desired_node_count
  tags                    = local.tags
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
  env = {
    OAUTH_ISSUER            = "https://issuer.example.com"
    OAUTH_AUDIENCE          = "api://weather"
    OAUTH_INTROSPECTION_URL = "https://issuer.example.com/oauth/introspect"
    OAUTH_CLIENT_ID         = "REPLACE"
    OAUTH_CLIENT_SECRET     = "REPLACE"
  }
  tags = local.tags
}

module "api_gateway" {
  source                = "./modules/api-gateway"
  name                  = "${local.name}-api"
  region                = var.region
  endpoint_domain       = "example.com"
  endpoint_port         = 443
  endpoint_protocol     = "https"
  lambda_authorizer_arn = module.lambda_authorizer.lambda_arn
  stage_names           = [var.api_gateway_stage_name]
  tags                  = local.tags
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

