variable "name" {
  description = "EKS cluster name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "VPC ID to deploy EKS into"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for control plane and nodes"
  type        = list(string)
}

variable "node_group_desired_size" {
  description = "Desired node count"
  type        = number
  default     = 3
}

variable "node_group_min_size" {
  description = "Min node count"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Max node count"
  type        = number
  default     = 10
}

variable "node_instance_types" {
  description = "Instance types for managed node group"
  type        = list(string)
  default     = ["t3.medium"]
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

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

