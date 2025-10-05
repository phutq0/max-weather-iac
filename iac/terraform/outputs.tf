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


output "lambda_authorizer_arn" {
  value       = module.lambda_authorizer.lambda_arn
  description = "Lambda authorizer ARN"
}

output "aws_load_balancer_controller_role_arn" {
  value       = module.iam.aws_load_balancer_controller_role_arn
  description = "AWS Load Balancer Controller IAM role ARN"
}

# EKS Module Outputs (EKS roles are managed by EKS module)
output "eks_cluster_role_arn" {
  value       = module.eks.cluster_role_arn
  description = "EKS cluster IAM role ARN"
}

output "eks_node_role_arn" {
  value       = module.eks.node_role_arn
  description = "EKS node group IAM role ARN"
}

output "oidc_provider_arn" {
  value       = module.iam.oidc_provider_arn
  description = "OIDC provider ARN"
}

output "cluster_autoscaler_role_arn" {
  value       = module.iam.cluster_autoscaler_role_arn
  description = "Cluster Autoscaler IAM role ARN"
}

output "app_irsa_role_arn" {
  value       = module.iam.app_irsa_role_arn
  description = "Application IRSA role ARN"
}

output "lambda_authorizer_role_arn" {
  value       = module.iam.lambda_authorizer_role_arn
  description = "Lambda authorizer IAM role ARN"
}

output "fluent_bit_role_arn" {
  value       = module.cloudwatch.fluent_bit_role_arn
  description = "FluentBit IAM role ARN for CloudWatch logs"
}

