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

# EKS Access Entries (AWS native access management)
# Provide a list of IAM principals and desired access policy/scope
variable "access_entries" {
  description = "List of EKS access entries to grant cluster access"
  type = list(object({
    principal_arn      = string                    # IAM user/role ARN
    policy_arn         = string                    # e.g. arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy
    access_scope_type  = string                    # \"cluster\" or \"namespace\"
    namespaces         = optional(list(string), [])
  }))
  default = []
}

# Legacy aws-auth mappings (optional) — to coexist with EKS Access Entries
variable "aws_auth_map_users" {
  description = "List of user mappings for aws-auth ConfigMap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_map_roles" {
  description = "List of role mappings for aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

