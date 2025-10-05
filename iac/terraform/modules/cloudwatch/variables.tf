variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., staging, production)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "log_group_prefix" {
  description = "Prefix for CloudWatch Log Groups"
  type        = string
  default     = "/eks"
}

variable "application_log_group_name" {
  description = "Application log group name (default: <prefix>/<cluster>/applications)"
  type        = string
  default     = null
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for IRSA (e.g. https://oidc.eks.<region>.amazonaws.com/id/xxxx)"
  type        = string
}

variable "fluent_bit_namespace" {
  description = "Namespace for aws-for-fluent-bit"
  type        = string
  default     = "amazon-cloudwatch"
}

variable "fluent_bit_service_account" {
  description = "Service account for aws-for-fluent-bit"
  type        = string
  default     = "fluent-bit"
}

variable "cloudwatch_agent_namespace" {
  description = "Namespace for cloudwatch-agent"
  type        = string
  default     = "amazon-cloudwatch"
}

variable "alarms_enabled" {
  description = "Enable CloudWatch alarms"
  type        = bool
  default     = true
}

variable "sns_email_subscriptions" {
  description = "List of emails to subscribe to SNS topic"
  type        = list(string)
  default     = []
}

variable "custom_latency_metric_namespace" {
  description = "Namespace for custom API latency metric (if app publishes one)"
  type        = string
  default     = "Application/WeatherAPI"
}

variable "custom_latency_metric_name" {
  description = "Metric name for API latency (p95 or average)"
  type        = string
  default     = "Latency"
}

variable "custom_latency_metric_dimensions" {
  description = "Map of dimensions for custom latency metric"
  type        = map(string)
  default     = { Service = "weather-api" }
}

variable "pod_restart_metric_namespace" {
  description = "Namespace for pod restart rate metric (if available)"
  type        = string
  default     = "Application/Kubernetes"
}

variable "pod_restart_metric_name" {
  description = "Metric name for pod restart rate"
  type        = string
  default     = "PodRestartRate"
}

variable "pod_restart_metric_dimensions" {
  description = "Map of dimensions for pod restart rate metric"
  type        = map(string)
  default     = { App = "weather-api" }
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

