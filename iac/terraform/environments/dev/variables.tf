variable "project_name" { type = string }
variable "region" { type = string }
variable "vpc_cidr" { type = string }
variable "eks_cluster_version" { type = string }
variable "node_instance_types" { type = list(string) }
variable "api_gateway_stage_name" { type = string }
variable "cloudwatch_retention_days" { type = number }
variable "enable_nat_gateway" { type = bool }
variable "node_desired_count" { type = number }
variable "node_min_count" { type = number }
variable "node_max_count" { type = number }
variable "enable_ebs_csi_driver" { type = bool }

# Node Group Configuration
variable "enable_spot_node_group" { type = bool }
variable "enable_ondemand_node_group" { type = bool }

# Spot Node Group Settings
variable "spot_node_instance_types" { type = list(string) }
variable "spot_node_min_size" { type = number }
variable "spot_node_max_size" { type = number }
variable "spot_node_desired_size" { type = number }

# On-Demand Node Group Settings
variable "ondemand_node_instance_types" { type = list(string) }
variable "ondemand_node_min_size" { type = number }
variable "ondemand_node_max_size" { type = number }
variable "ondemand_node_desired_size" { type = number }

# ECR Configuration
variable "ecr_repository_names" { type = list(string) }
variable "ecr_image_tag_mutability" { type = string }
variable "ecr_scan_on_push" { type = bool }
variable "ecr_encryption_type" { type = string }
variable "ecr_enable_lifecycle_policy" { type = bool }
variable "ecr_max_image_count" { type = number }
variable "ecr_max_image_age_days" { type = number }