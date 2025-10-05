output "repository_urls" {
  description = "URLs of the created ECR repositories"
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}

output "repository_arns" {
  description = "ARNs of the created ECR repositories"
  value       = { for k, v in aws_ecr_repository.this : k => v.arn }
}

output "repository_names" {
  description = "Names of the created ECR repositories"
  value       = { for k, v in aws_ecr_repository.this : k => v.name }
}

output "registry_id" {
  description = "Registry ID of the ECR repositories"
  value       = { for k, v in aws_ecr_repository.this : k => v.registry_id }
}

output "repository_uris" {
  description = "Full repository URIs for Docker commands"
  value       = { for k, v in aws_ecr_repository.this : k => "${v.registry_id}.dkr.ecr.${var.region}.amazonaws.com/${v.name}" }
}

# VPC Endpoint Outputs
output "ecr_api_endpoint_id" {
  description = "ID of the ECR API VPC endpoint"
  value       = var.enable_private_endpoint ? aws_vpc_endpoint.ecr_api[0].id : null
}

output "ecr_dkr_endpoint_id" {
  description = "ID of the ECR DKR VPC endpoint"
  value       = var.enable_private_endpoint ? aws_vpc_endpoint.ecr_dkr[0].id : null
}

output "ecr_endpoint_security_group_id" {
  description = "ID of the security group for ECR endpoints"
  value       = var.enable_private_endpoint ? aws_security_group.ecr_endpoint[0].id : null
}

# Lifecycle Policy Outputs
output "lifecycle_policy_applied" {
  description = "Whether lifecycle policy was applied to repositories"
  value       = var.enable_lifecycle_policy
}

# Repository Policy Outputs
output "repository_policy_applied" {
  description = "Whether repository policy was applied to repositories"
  value       = var.enable_repository_policy
}
