variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
  validation {
    condition = length(var.repository_names) > 0
    error_message = "At least one repository name must be provided."
  }
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either 'MUTABLE' or 'IMMUTABLE'."
  }
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for the repository"
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Encryption type must be either 'AES256' or 'KMS'."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (required when encryption_type is KMS)"
  type        = string
  default     = null
  validation {
    condition = var.encryption_type != "KMS" || var.kms_key_arn != null
    error_message = "KMS key ARN is required when encryption_type is KMS."
  }
}

# Lifecycle Policy Configuration
variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policy for repositories"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of images to keep in each repository"
  type        = number
  default     = 10
  validation {
    condition     = var.max_image_count > 0
    error_message = "Maximum image count must be greater than 0."
  }
}

variable "max_image_age_days" {
  description = "Maximum age in days for untagged images before deletion"
  type        = number
  default     = 7
  validation {
    condition     = var.max_image_age_days > 0
    error_message = "Maximum image age must be greater than 0."
  }
}

variable "lifecycle_policy" {
  description = "Custom lifecycle policy JSON (overrides default policy if provided)"
  type        = any
  default     = null
}

# Repository Policy Configuration
variable "enable_repository_policy" {
  description = "Enable repository policy for cross-account access"
  type        = bool
  default     = false
}

variable "allowed_principals" {
  description = "List of AWS principals (ARNs) allowed to access the repositories"
  type        = list(string)
  default     = []
}

variable "repository_policy" {
  description = "Custom repository policy JSON (overrides default policy if provided)"
  type        = any
  default     = null
}

# VPC Endpoint Configuration
variable "enable_private_endpoint" {
  description = "Enable VPC endpoints for private ECR access"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for private endpoints (required when enable_private_endpoint is true)"
  type        = string
  default     = null
  validation {
    condition = !var.enable_private_endpoint || var.vpc_id != null
    error_message = "VPC ID is required when enable_private_endpoint is true."
  }
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for VPC endpoints (required when enable_private_endpoint is true)"
  type        = list(string)
  default     = []
  validation {
    condition = !var.enable_private_endpoint || length(var.private_subnet_ids) > 0
    error_message = "Private subnet IDs are required when enable_private_endpoint is true."
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR block for security group rules (required when enable_private_endpoint is true)"
  type        = string
  default     = null
  validation {
    condition = !var.enable_private_endpoint || var.vpc_cidr != null
    error_message = "VPC CIDR is required when enable_private_endpoint is true."
  }
}

# General Configuration
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "ecr"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
