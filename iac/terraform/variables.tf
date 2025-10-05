variable "project_name" {
  description = "Project name"
  type        = string
  default     = "max-weather"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be 'dev', 'staging' or 'production'"
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Enable creation of NAT gateways"
  type        = bool
  default     = true
}

variable "eks_cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.28"
}

variable "node_instance_types" {
  description = "Node instance types"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "min_node_count" {
  description = "Minimum nodes in the node group"
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "Maximum nodes in the node group"
  type        = number
  default     = 10
}

variable "desired_node_count" {
  description = "Desired nodes in the node group"
  type        = number
  default     = 3
}

variable "api_gateway_stage_name" {
  description = "API Gateway stage name"
  type        = string
}

variable "cloudwatch_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI driver addon for persistent volume support"
  type        = bool
  default     = true
}

# Node Group Configuration
variable "enable_spot_node_group" {
  description = "Enable spot instance node group"
  type        = bool
  default     = true
}

variable "enable_ondemand_node_group" {
  description = "Enable on-demand instance node group"
  type        = bool
  default     = true
}

# Spot Node Group Settings
variable "spot_node_instance_types" {
  description = "Instance types for spot node group"
  type        = list(string)
  default     = ["t3.medium", "t3.large"]
}

variable "spot_node_min_size" {
  description = "Minimum nodes in spot node group"
  type        = number
  default     = 0
}

variable "spot_node_max_size" {
  description = "Maximum nodes in spot node group"
  type        = number
  default     = 5
}

variable "spot_node_desired_size" {
  description = "Desired nodes in spot node group"
  type        = number
  default     = 1
}

# On-Demand Node Group Settings
variable "ondemand_node_instance_types" {
  description = "Instance types for on-demand node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "ondemand_node_min_size" {
  description = "Minimum nodes in on-demand node group"
  type        = number
  default     = 1
}

variable "ondemand_node_max_size" {
  description = "Maximum nodes in on-demand node group"
  type        = number
  default     = 3
}

variable "ondemand_node_desired_size" {
  description = "Desired nodes in on-demand node group"
  type        = number
  default     = 2
}

# ECR Settings
variable "ecr_repository_names" {
  description = "ECR repository names"
  type        = list(string)
  default     = ["max-weather-dev"]
}

variable "ecr_image_tag_mutability" {
  description = "ECR image tag mutability"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "ECR scan on push"
  type        = bool
  default     = true
}

variable "ecr_encryption_type" {
  description = "ECR encryption type"
  type        = string
  default     = "AES256"
}

variable "ecr_enable_lifecycle_policy" {
  description = "ECR enable lifecycle policy"
  type        = bool
  default     = true
}

variable "ecr_max_image_count" {
  description = "ECR max image count"
  type        = number
  default     = 10
}

variable "ecr_max_image_age_days" {
  description = "ECR max image age days"
  type        = number
  default     = 7
}