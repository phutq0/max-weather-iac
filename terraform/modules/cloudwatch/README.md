CloudWatch integration for EKS

Features:
- App log group with environment-based retention (7d staging, 30d production)
- SNS topic for alerts (email subscriptions)
- IAM role via IRSA for aws-for-fluent-bit chart
- Helm installs: aws-for-fluent-bit, cloudwatch-agent
- Alarms: CPU, memory, pod restarts, API latency

Example usage:

```hcl
module "cloudwatch" {
  source                 = "./terraform/modules/cloudwatch"
  region                 = var.region
  environment            = var.environment
  cluster_name           = module.eks.cluster_name
  oidc_provider_arn      = module.eks.cluster_oidc_provider_arn
  oidc_provider_url      = module.eks.cluster_oidc_issuer
  sns_email_subscriptions = ["alerts@example.com"]
  tags = {
    Environment = var.environment
    Project     = "max-weather"
  }
}
```

