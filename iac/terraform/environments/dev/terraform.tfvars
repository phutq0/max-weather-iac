region                    = "ap-southeast-2"
project_name              = "max-weather"
vpc_cidr                  = "10.100.0.0/16"
enable_nat_gateway        = true
eks_cluster_version       = "1.32"
node_instance_types       = ["t3.small"]
api_gateway_stage_name    = "dev"
cloudwatch_retention_days = 7
node_desired_count        = 3
node_min_count            = 1
node_max_count            = 4
enable_ebs_csi_driver     = false

# Node Group Configuration
enable_spot_node_group   = true
enable_ondemand_node_group = true

# Spot Node Group Settings
spot_node_instance_types = ["t3.small"]
spot_node_min_size      = 0
spot_node_max_size      = 5
spot_node_desired_size  = 2

# On-Demand Node Group Settings
ondemand_node_instance_types = ["t3.small"]
ondemand_node_min_size      = 0
ondemand_node_max_size      = 2
ondemand_node_desired_size  = 1

ecr_repository_names = ["max-weather-dev"]
ecr_image_tag_mutability = "MUTABLE"
ecr_scan_on_push = true
ecr_encryption_type = "AES256"
ecr_enable_lifecycle_policy = true
ecr_max_image_count = 10
ecr_max_image_age_days = 7