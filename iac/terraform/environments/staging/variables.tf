variable "project_name" { type = string }
variable "region" { type = string }
variable "vpc_cidr" { type = string }
variable "eks_cluster_version" { type = string }
variable "node_instance_types" { type = list(string) }
variable "api_gateway_stage_name" { type = string }
variable "cloudwatch_retention_days" { type = number }
variable "enable_nat_gateway" { type = bool }
variable "openweather_api_key" { type = string }
variable "eks_access_entries" { type = list(object({
  principal_arn      = string
  policy_arn         = string
  access_scope_type  = string
  namespaces         = optional(list(string), [])
})) }
variable "aws_auth_map_users" { type = list(object({
  userarn  = string
  username = string
  groups   = list(string)
})) }
variable "aws_auth_map_roles" { type = list(object({
  rolearn  = string
  username = string
  groups   = list(string)
})) }

# Karpenter
variable "enable_karpenter" { type = bool }
variable "karpenter_service_account" { type = string }