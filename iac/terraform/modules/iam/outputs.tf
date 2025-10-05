# EKS cluster and node role outputs are managed by the EKS module

output "oidc_provider_arn" {
  value       = data.aws_iam_openid_connect_provider.this.arn
  description = "OIDC provider ARN"
}

output "external_dns_role_arn" {
  value       = try(aws_iam_role.external_dns[0].arn, null)
  description = "IRSA role ARN for ExternalDNS (if enabled)"
}

output "cluster_autoscaler_role_arn" {
  value       = data.aws_iam_role.cluster_autoscaler.arn
  description = "IRSA role ARN for Cluster Autoscaler"
}

output "app_irsa_role_arn" {
  value       = aws_iam_role.app_irsa.arn
  description = "IRSA role ARN for application service account"
}

output "lambda_authorizer_role_arn" {
  value       = aws_iam_role.lambda_authorizer.arn
  description = "Lambda authorizer execution role ARN"
}

output "aws_load_balancer_controller_role_arn" {
  value       = aws_iam_role.aws_load_balancer_controller.arn
  description = "AWS Load Balancer Controller role ARN"
}

