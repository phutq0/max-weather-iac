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
  min_node_count            = var.node_min_count
  max_node_count            = var.node_max_count
  desired_node_count        = var.node_desired_count
  api_gateway_stage_name    = var.api_gateway_stage_name
  cloudwatch_retention_days = var.cloudwatch_retention_days
  enable_ebs_csi_driver     = var.enable_ebs_csi_driver
  
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

  # ECR Settings
  ecr_repository_names = var.ecr_repository_names
  ecr_image_tag_mutability = var.ecr_image_tag_mutability
  ecr_scan_on_push = var.ecr_scan_on_push
  ecr_encryption_type = var.ecr_encryption_type
  ecr_enable_lifecycle_policy = var.ecr_enable_lifecycle_policy
  ecr_max_image_count = var.ecr_max_image_count
  ecr_max_image_age_days = var.ecr_max_image_age_days
}

