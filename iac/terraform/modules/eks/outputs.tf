output "cluster_name" {
  value       = aws_eks_cluster.this.name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "EKS API server endpoint"
}

output "cluster_oidc_issuer" {
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
  description = "OIDC issuer URL"
}

output "cluster_oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.this.arn
  description = "OIDC provider ARN for IRSA"
}

output "spot_node_group_name" {
  value       = var.enable_spot_node_group ? aws_eks_node_group.spot[0].node_group_name : null
  description = "Spot node group name"
}

output "ondemand_node_group_name" {
  value       = var.enable_ondemand_node_group ? aws_eks_node_group.ondemand[0].node_group_name : null
  description = "On-demand node group name"
}

output "ebs_csi_role_arn" {
  value       = var.enable_ebs_csi_driver ? aws_iam_role.ebs_csi[0].arn : null
  description = "EBS CSI driver IAM role ARN"
}

output "cluster_role_arn" {
  value       = aws_iam_role.cluster.arn
  description = "EKS cluster IAM role ARN"
}

output "node_role_arn" {
  value       = aws_iam_role.nodes.arn
  description = "EKS node group IAM role ARN"
}

