# Multiple Repositories Example
module "multi_ecr" {
  source = "../../"
  
  repository_names = [
    "frontend",
    "backend", 
    "api-gateway",
    "database"
  ]
  
  # Production settings
  image_tag_mutability = "IMMUTABLE"
  scan_on_push        = true
  encryption_type     = "AES256"
  
  # Lifecycle policy
  enable_lifecycle_policy = true
  max_image_count        = 20
  max_image_age_days     = 14
  
  tags = {
    Environment = "production"
    Project     = "microservices"
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }
}

# Output repository information
output "repository_urls" {
  value = module.multi_ecr.repository_urls
}

output "repository_uris" {
  value = module.multi_ecr.repository_uris
}
