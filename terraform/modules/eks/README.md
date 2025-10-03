AWS EKS module

Creates an EKS cluster (v1.29 by default) with:
- Managed node group (t3.medium) with autoscaling (2-10, desired 3)
- OIDC provider for IRSA
- Control plane CloudWatch logging
- Private endpoint enabled with public access for management
- Security groups for cluster and nodes
- Addons: CoreDNS, kube-proxy, EBS CSI driver

Example usage:

```hcl
module "eks" {
  source = "./terraform/modules/eks"

  name                 = "project-staging"
  region               = "us-east-1"
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  node_instance_types  = ["t3.medium"]
  node_group_min_size  = 2
  node_group_max_size  = 10
  node_group_desired_size = 3
  version              = "1.29"

  tags = {
    Environment = "staging"
    Project     = "max-weather"
  }
}
```

