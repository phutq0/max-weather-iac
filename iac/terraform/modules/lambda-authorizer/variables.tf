variable "name" {
  description = "Lambda authorizer name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_subnet_ids" {
  description = "Optional VPC subnet IDs"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Optional VPC security group IDs"
  type        = list(string)
  default     = []
}

variable "env" {
  description = "Environment variables for Lambda"
  type        = map(string)
  default     = {}
}

variable "api_gateway_execution_arn" {
  description = "API Gateway execution ARN for Lambda permission"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

