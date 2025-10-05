# Private Endpoints Example
module "private_ecr" {
  source = "../../"
  
  repository_names = ["secure-app", "internal-service"]
  
  # Enable private VPC endpoints
  enable_private_endpoint = true
  vpc_id                 = "vpc-12345678"
  private_subnet_ids     = ["subnet-12345678", "subnet-87654321"]
  vpc_cidr              = "10.0.0.0/16"
  
  # Security settings
  image_tag_mutability = "IMMUTABLE"
  scan_on_push        = true
  encryption_type     = "KMS"
  kms_key_arn        = "arn:aws:kms:us-east-1:111111111111:key/12345678-1234-1234-1234-123456789012"
  
  # Lifecycle policy
  enable_lifecycle_policy = true
  max_image_count        = 10
  max_image_age_days     = 7
  
  tags = {
    Environment = "production"
    Project     = "secure-services"
    Owner       = "security-team"
    Network     = "private"
  }
}

# Output VPC endpoint information
output "ecr_endpoints" {
  value = {
    api_endpoint_id = module.private_ecr.ecr_api_endpoint_id
    dkr_endpoint_id = module.private_ecr.ecr_dkr_endpoint_id
    security_group_id = module.private_ecr.ecr_endpoint_security_group_id
  }
}

output "repository_urls" {
  value = module.private_ecr.repository_urls
}
