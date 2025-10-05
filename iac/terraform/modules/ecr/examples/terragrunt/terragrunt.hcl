# Terragrunt configuration for ECR module
terraform {
  source = "../../"
}

inputs = {
  repository_names = [
    "my-application",
    "my-service",
    "my-worker"
  ]
  
  # Production settings
  image_tag_mutability = "IMMUTABLE"
  scan_on_push        = true
  encryption_type     = "AES256"
  
  # Lifecycle policy
  enable_lifecycle_policy = true
  max_image_count        = 15
  max_image_age_days     = 10
  
  # Cross-account access
  enable_repository_policy = true
  allowed_principals = [
    "arn:aws:iam::123456789012:root",
    "arn:aws:iam::987654321098:root"
  ]
  
  tags = {
    Environment = "production"
    Project     = "my-project"
    Owner       = "platform-team"
    ManagedBy   = "terragrunt"
  }
}
