# Custom Lifecycle Policy Example
module "custom_lifecycle_ecr" {
  source = "../../"
  
  repository_names = ["production-app", "staging-app"]
  
  # Custom lifecycle policy
  lifecycle_policy = {
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 production images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod", "release"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete development images older than 3 days"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["dev", "feature"]
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 3
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 4
        description  = "Keep staging images for 7 days"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["staging"]
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  }
  
  # Security settings
  image_tag_mutability = "IMMUTABLE"
  scan_on_push        = true
  encryption_type     = "AES256"
  
  tags = {
    Environment = "multi-stage"
    Project     = "application"
    Owner       = "devops-team"
  }
}

output "repository_urls" {
  value = module.custom_lifecycle_ecr.repository_urls
}
