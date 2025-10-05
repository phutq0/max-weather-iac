variable "name" {
  description = "API name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "endpoint_uri" {
  description = "Backend URI"
  type        = string
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

variable "openweather_api_key" {
  description = "OpenWeather API key for weather data access"
  type        = string
  sensitive   = true
}

