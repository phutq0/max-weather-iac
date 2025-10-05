# AWS ECR Terraform Module

This module creates and manages AWS Elastic Container Registry (ECR) repositories with comprehensive configuration options for lifecycle policies, access control, and security features.

## Features

- **Multiple Repositories**: Create single or multiple ECR repositories
- **Image Tag Mutability**: Support for both mutable and immutable image tags
- **Image Scanning**: Configurable scan-on-push functionality
- **Encryption**: Support for AES256 and KMS encryption
- **Lifecycle Policies**: Automatic cleanup of old images with configurable rules
- **Access Control**: Repository policies for cross-account access
- **Private Endpoints**: VPC endpoints for private ECR access
- **Security**: Comprehensive security configurations

## Usage

### Basic Usage

```hcl
module "ecr" {
  source = "./modules/ecr"
  
  repository_names = ["my-app", "my-service"]
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Advanced Usage with All Features

```hcl
module "ecr" {
  source = "./modules/ecr"
  
  # Repository Configuration
  repository_names     = ["frontend", "backend", "api"]
  image_tag_mutability = "IMMUTABLE"
  scan_on_push        = true
  
  # Encryption
  encryption_type = "KMS"
  kms_key_arn     = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  
  # Lifecycle Policy
  enable_lifecycle_policy = true
  max_image_count        = 20
  max_image_age_days     = 14
  
  # Repository Policy for Cross-Account Access
  enable_repository_policy = true
  allowed_principals = [
    "arn:aws:iam::123456789012:root",
    "arn:aws:iam::987654321098:user/cross-account-user"
  ]
  
  # Private Endpoints
  enable_private_endpoint = true
  vpc_id                 = "vpc-12345678"
  private_subnet_ids     = ["subnet-12345678", "subnet-87654321"]
  vpc_cidr              = "10.0.0.0/16"
  
  tags = {
    Environment = "production"
    Project     = "my-project"
    Owner       = "platform-team"
  }
}
```

### Custom Lifecycle Policy

```hcl
module "ecr" {
  source = "./modules/ecr"
  
  repository_names = ["my-app"]
  
  # Custom lifecycle policy
  lifecycle_policy = {
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 production images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod"]
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
          tagPrefixList = ["dev"]
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  }
}
```

### Cross-Account Access

```hcl
module "ecr" {
  source = "./modules/ecr"
  
  repository_names = ["shared-lib"]
  
  enable_repository_policy = true
  allowed_principals = [
    "arn:aws:iam::123456789012:root",
    "arn:aws:iam::987654321098:role/CrossAccountRole"
  ]
  
  # Custom repository policy
  repository_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountPull"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::987654321098:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  }
}
```

## Examples

### Single Repository

```hcl
module "single_ecr" {
  source = "./modules/ecr"
  
  repository_names = ["my-application"]
  tags = {
    Environment = "dev"
  }
}
```

### Multiple Repositories with Different Configurations

```hcl
module "multi_ecr" {
  source = "./modules/ecr"
  
  repository_names     = ["frontend", "backend", "database"]
  image_tag_mutability = "IMMUTABLE"
  scan_on_push        = true
  encryption_type     = "AES256"
  
  enable_lifecycle_policy = true
  max_image_count        = 15
  max_image_age_days     = 10
  
  tags = {
    Environment = "production"
    Project     = "microservices"
  }
}
```

### Development Environment with Cost Optimization

```hcl
module "dev_ecr" {
  source = "./modules/ecr"
  
  repository_names = ["dev-app"]
  
  # Aggressive cleanup for dev environment
  enable_lifecycle_policy = true
  max_image_count        = 3
  max_image_age_days     = 2
  
  tags = {
    Environment = "development"
    CostCenter  = "engineering"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| repository_names | List of ECR repository names to create | `list(string)` | n/a | yes |
| image_tag_mutability | Image tag mutability setting | `string` | `"MUTABLE"` | no |
| scan_on_push | Enable image scanning on push | `bool` | `true` | no |
| encryption_type | Encryption type (AES256 or KMS) | `string` | `"AES256"` | no |
| kms_key_arn | KMS key ARN for encryption | `string` | `null` | no |
| enable_lifecycle_policy | Enable lifecycle policy | `bool` | `true` | no |
| max_image_count | Maximum number of images to keep | `number` | `10` | no |
| max_image_age_days | Maximum age for untagged images | `number` | `7` | no |
| lifecycle_policy | Custom lifecycle policy JSON | `any` | `null` | no |
| enable_repository_policy | Enable repository policy | `bool` | `false` | no |
| allowed_principals | List of allowed AWS principals | `list(string)` | `[]` | no |
| repository_policy | Custom repository policy JSON | `any` | `null` | no |
| enable_private_endpoint | Enable VPC endpoints | `bool` | `false` | no |
| vpc_id | VPC ID for private endpoints | `string` | `null` | no |
| private_subnet_ids | Private subnet IDs for endpoints | `list(string)` | `[]` | no |
| vpc_cidr | VPC CIDR block | `string` | `null` | no |
| name_prefix | Prefix for resource names | `string` | `"ecr"` | no |
| region | AWS region | `string` | `"us-east-1"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_urls | URLs of the created ECR repositories |
| repository_arns | ARNs of the created ECR repositories |
| repository_names | Names of the created ECR repositories |
| registry_id | Registry ID of the ECR repositories |
| repository_uris | Full repository URIs for Docker commands |
| ecr_api_endpoint_id | ID of the ECR API VPC endpoint |
| ecr_dkr_endpoint_id | ID of the ECR DKR VPC endpoint |
| ecr_endpoint_security_group_id | ID of the security group for ECR endpoints |
| lifecycle_policy_applied | Whether lifecycle policy was applied |
| repository_policy_applied | Whether repository policy was applied |

## Best Practices

### Security
- Use immutable image tags in production
- Enable scan-on-push for vulnerability detection
- Use KMS encryption for sensitive repositories
- Implement least-privilege repository policies

### Cost Optimization
- Configure lifecycle policies to clean up old images
- Use appropriate image retention periods
- Consider using private endpoints to reduce data transfer costs

### Naming Conventions
- Use lowercase repository names
- Include environment and project information in tags
- Follow consistent naming patterns across repositories

### Lifecycle Management
- Set appropriate image count limits based on your deployment frequency
- Configure age-based cleanup for untagged images
- Use different policies for different environments

## Troubleshooting

### Common Issues

1. **Repository name validation errors**: Ensure repository names are lowercase and follow ECR naming conventions
2. **KMS key access**: Verify KMS key permissions when using KMS encryption
3. **Cross-account access**: Ensure repository policies include correct principal ARNs
4. **VPC endpoint issues**: Verify subnet IDs and security group configurations

### Validation Rules

- Repository names are automatically converted to lowercase
- Invalid characters in repository names are replaced with hyphens
- KMS key ARN is required when encryption_type is "KMS"
- VPC ID and subnet IDs are required when enable_private_endpoint is true

## License

This module is released under the MIT License.
