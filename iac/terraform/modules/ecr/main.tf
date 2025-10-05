terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  # Ensure repository names are lowercase and follow ECR naming conventions
  repository_names = [for name in var.repository_names : lower(replace(name, "/[^a-z0-9-]/", "-"))]
  
  # Default lifecycle policy if none provided
  default_lifecycle_policy = {
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.max_image_count} images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest", "dev", "staging", "prod", "v"]
          countType     = "imageCountMoreThan"
          countNumber   = var.max_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than ${var.max_image_age_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.max_image_age_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  }
  
  # Merge custom lifecycle policy with defaults if provided
  lifecycle_policy = var.lifecycle_policy != null ? var.lifecycle_policy : local.default_lifecycle_policy
  
  # Default repository policy for cross-account access
  default_repository_policy = var.repository_policy != null ? var.repository_policy : {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPushPull"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_principals
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
}

# ECR Repositories
resource "aws_ecr_repository" "this" {
  for_each = toset(local.repository_names)
  
  name                 = each.value
  image_tag_mutability = var.image_tag_mutability
  
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  
  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key_arn : null
  }
  
  tags = merge(var.tags, {
    Name = each.value
  })
}

# Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "this" {
  for_each = var.enable_lifecycle_policy ? aws_ecr_repository.this : {}
  
  repository = each.value.name
  policy     = jsonencode(local.lifecycle_policy)
}

# Repository Policy
resource "aws_ecr_repository_policy" "this" {
  for_each = var.enable_repository_policy ? aws_ecr_repository.this : {}
  
  repository = each.value.name
  policy     = jsonencode(local.default_repository_policy)
}

# VPC Endpoint for ECR API (if private access is enabled)
resource "aws_vpc_endpoint" "ecr_api" {
  count = var.enable_private_endpoint ? 1 : 0
  
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.ecr_endpoint[0].id]
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecr-api-endpoint"
  })
}

# VPC Endpoint for ECR DKR (if private access is enabled)
resource "aws_vpc_endpoint" "ecr_dkr" {
  count = var.enable_private_endpoint ? 1 : 0
  
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.ecr_endpoint[0].id]
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecr-dkr-endpoint"
  })
}

# Security Group for ECR VPC Endpoints
resource "aws_security_group" "ecr_endpoint" {
  count = var.enable_private_endpoint ? 1 : 0
  
  name        = "${var.name_prefix}-ecr-endpoint-sg"
  description = "Security group for ECR VPC endpoints"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecr-endpoint-sg"
  })
}
