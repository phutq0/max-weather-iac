AWS VPC module for ALB + EKS

Creates VPC with 3 public and 3 private subnets across AZs, IGW, NAT gateways per AZ, route tables, and VPC endpoints for ECR, S3, and CloudWatch Logs.

Inputs: see `variables.tf`
Outputs: see `outputs.tf`

Example usage:

```hcl
module "vpc" {
  source = "./terraform/modules/vpc"

  name                  = "project-staging"
  region                = "us-east-1"
  vpc_cidr              = "10.0.0.0/16"
  public_subnet_cidrs   = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  tags = {
    Environment = "staging"
    Project     = "max-weather"
  }
}
```

