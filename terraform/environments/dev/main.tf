terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "root" {
  source = "../../"

  project_name              = var.project_name
  environment               = "dev"
  region                    = var.region
  vpc_cidr                  = var.vpc_cidr
  enable_nat_gateway        = var.enable_nat_gateway
  eks_cluster_version       = var.eks_cluster_version
  node_instance_types       = var.node_instance_types
  min_node_count            = 1
  max_node_count            = 3
  desired_node_count        = 2
  api_gateway_stage_name    = var.api_gateway_stage_name
  cloudwatch_retention_days = var.cloudwatch_retention_days
}

