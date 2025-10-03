### Max Weather - System Architecture

#### Overview
The system provides a weather API backed by AWS infrastructure with Terraform-managed IaC, EKS for compute, API Gateway for edge, and observability via CloudWatch and Fluent Bit.

#### ASCII Architecture Diagram
```
Users
  |
  v
+---------------------+          +-----------------------+
|  Amazon API Gateway |<-------->| Lambda Authorizer     |
|  (REST, stages)     |  JWT/IRSA| (OAuth2/JWT)          |
+----------+----------+          +-----------+-----------+
           |                                   
           | HTTP proxy (mTLS/TLS)
           v
    +------+-------------------------------+
    |  AWS NLB (ingress-nginx, TLS at LB)  |
    +------+-------------------------------+
           |
           v
  +--------+-----------------------------------------------+
  |                Amazon EKS (Private)                    |
  |  - nginx-ingress controller                            |
  |  - Weather API Deployment/Service (3 replicas)         |
  |  - HPA (CPU/Mem/Custom metrics)                        |
  |  - ServiceAccount (IRSA) for AWS access                |
  |  - Fluent Bit DaemonSet (logs -> CloudWatch)           |
  +--------+-----------------------------------------------+
           |
           v
  +--------+-----------------------------------------------+
  |                VPC (DNS, IGW, NAT per AZ)              |
  |  - 3 public subnets (ALB/NLB)                          |
  |  - 3 private subnets (EKS nodes)                       |
  |  - Route tables, IGW, NAT GW (HA)                      |
  |  - VPC endpoints: S3, ECR, CloudWatch                  |
  +--------+-----------------------------------------------+
           |
           v
  +--------+-----------------------------------------------+
  | CloudWatch Logs & Metrics, SNS (alerts)                |
  | - Control plane logs                                   |
  | - App logs (Fluent Bit)                                |
  | - Container Insights, Alarms                           |
  +--------------------------------------------------------+
```

#### Components
- VPC: 3 public + 3 private subnets across AZs, IGW, NAT, endpoints (S3/ECR/Logs).
- EKS: v1.29 control plane, managed node groups, OIDC for IRSA, addons (CoreDNS, kube-proxy, EBS CSI).
- Ingress: nginx-ingress on NLB with TLS termination, rate limiting, custom errors.
- API Gateway: REST API proxy to NLB, stages, usage plan, API keys, Lambda Authorizer.
- Lambda Authorizer: Node.js OAuth2/JWT validation with caching.
- Observability: aws-for-fluent-bit to CloudWatch, Container Insights, alarms via SNS.

#### Data Flow
1. Client requests hit API Gateway with API key + Authorization header.
2. Lambda Authorizer validates token (JWT or introspection), returns IAM policy.
3. API Gateway proxies to NLB → ingress-nginx → Service → Weather API pods.
4. Weather API proxies to OpenWeatherMap; responses flow back through the chain.
5. Logs from containers are shipped by Fluent Bit to CloudWatch. Metrics exposed at `/metrics` and scraped by external systems if configured.

#### Security Architecture
- IRSA: fine-grained IAM for Kubernetes service accounts (Fluent Bit, app, controllers).
- Private subnets for nodes; control plane private endpoint with restricted public access.
- TLS at NLB and API Gateway. ACM certificates for ingress.
- Least-privilege IAM policies; optional permission boundaries.
- NetworkPolicies restricting ingress/egress and DNS-only egress to external APIs.

#### High Availability
- Multi-AZ subnets; one NAT per AZ; NLB across AZs.
- EKS managed node groups with multiple replicas and HPA for pods.
- API Gateway regional endpoints with stage deployments.

#### Scaling Strategy
- HPA scales Weather API (CPU/Mem/custom metrics).
- Node groups scale via Cluster Autoscaler.
- API Gateway throttling and usage plans protect backend.

#### Disaster Recovery
- Remote Terraform state in S3 with DynamoDB locking.
- Stateless application with rebuilt images from CI; infra re-creatable via Terraform.
- CloudWatch logs retained per environment; alarms notify via SNS.
- Back up critical configuration (tfvars, environment secrets) in secure secret manager.

