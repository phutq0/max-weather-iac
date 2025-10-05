# Single Repository Example
module "single_ecr" {
  source = "../../"
  
  repository_names = ["my-application"]
  
  tags = {
    Environment = "production"
    Project     = "my-project"
    Owner       = "platform-team"
  }
}

# Output the repository URL for use in other modules
output "repository_url" {
  value = module.single_ecr.repository_urls["my-application"]
}
