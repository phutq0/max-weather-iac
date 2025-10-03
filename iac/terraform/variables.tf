variable "project_name" {
  description = "Project name"
  type        = string
  default     = "max-weather"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "environment must be 'staging' or 'production'"
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

