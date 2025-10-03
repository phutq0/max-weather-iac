output "eks_cluster_role_arn" {
  value       = aws_iam_role.eks_cluster.arn
  description = "EKS cluster role ARN"
}

output "eks_node_role_arn" {
  value       = aws_iam_role.eks_nodes.arn
  description = "EKS node role ARN"
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.this.arn
  description = "OIDC provider ARN"
}

output "alb_controller_role_arn" {
  value       = aws_iam_role.alb_controller.arn
  description = "IRSA role ARN for AWS Load Balancer Controller"
}

output "fluent_bit_role_arn" {
  value       = aws_iam_role.fluent_bit.arn
  description = "IRSA role ARN for Fluent Bit"
}

output "external_dns_role_arn" {
  value       = try(aws_iam_role.external_dns[0].arn, null)
  description = "IRSA role ARN for ExternalDNS (if enabled)"
}

output "cluster_autoscaler_role_arn" {
  value       = aws_iam_role.cluster_autoscaler.arn
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

