variable "name" {
  description = "API name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "endpoint_domain" {
  description = "Backend LB domain (e.g., abc.execute-api...)"
  type        = string
}

variable "endpoint_port" {
  description = "Backend port"
  type        = number
  default     = 443
}

variable "endpoint_protocol" {
  description = "Backend protocol (http or https)"
  type        = string
  default     = "https"
}

variable "stage_names" {
  description = "Stage names to create"
  type        = list(string)
  default     = ["staging", "production"]
}

variable "lambda_authorizer_arn" {
  description = "Lambda authorizer function ARN"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

