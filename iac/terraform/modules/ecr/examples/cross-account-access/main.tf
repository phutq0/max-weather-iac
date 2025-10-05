# Cross-Account Access Example
module "shared_ecr" {
  source = "../../"
  
  repository_names = ["shared-library", "common-utils"]
  
  # Enable cross-account access
  enable_repository_policy = true
  allowed_principals = [
    "arn:aws:iam::123456789012:root",           # Production account
    "arn:aws:iam::987654321098:root",           # Staging account
    "arn:aws:iam::555555555555:user/ci-user"    # CI/CD user
  ]
  
  # Custom repository policy for fine-grained access
  repository_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowProductionPull"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      },
      {
        Sid    = "AllowStagingPushPull"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::987654321098:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  }
  
  # Security settings
  image_tag_mutability = "IMMUTABLE"
  scan_on_push        = true
  encryption_type     = "KMS"
  kms_key_arn        = "arn:aws:kms:us-east-1:111111111111:key/12345678-1234-1234-1234-123456789012"
  
  tags = {
    Environment = "shared"
    Project     = "shared-services"
    Owner       = "platform-team"
  }
}

output "shared_repository_urls" {
  value = module.shared_ecr.repository_urls
}
