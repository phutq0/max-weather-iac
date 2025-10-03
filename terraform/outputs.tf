output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Private subnet IDs"
}

output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster endpoint"
}

output "eks_oidc_issuer" {
  value       = module.eks.cluster_oidc_issuer
  description = "EKS OIDC issuer"
}

output "cloudwatch_log_group" {
  value       = module.cloudwatch.application_log_group_name
  description = "Application log group"
}

output "sns_alerts_topic_arn" {
  value       = module.cloudwatch.sns_topic_arn
  description = "SNS alerts topic ARN"
}

output "api_gateway_urls" {
  value       = module.api_gateway.stage_invoke_urls
  description = "API Gateway URLs"
}

output "lambda_authorizer_arn" {
  value       = module.lambda_authorizer.lambda_arn
  description = "Lambda authorizer ARN"
}

