### Deployment Guide

#### Prerequisites
- AWS account, CLI configured with permissions
- Terraform >= 1.5, kubectl, Helm, jq installed
- S3 bucket + DynamoDB table for Terraform state/lock
- ACM certificates for ingress/API Gateway
- ECR repository (or allow pipeline to create)
- OpenWeatherMap API key

#### Terraform Setup
1. Copy backend templates and set your S3 bucket and DynamoDB table:
   - `terraform/main.tf` backend or per-environment `backend.tf`
2. Initialize and plan/apply per environment:

```bash
cd terraform/environments/staging
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

cd ../production
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

#### Kubernetes Deployment
1. Update kubeconfig:
```bash
aws eks update-kubeconfig --region us-east-1 --name <cluster-name>
```
2. Apply base namespace, RBAC, and network policies:
```bash
kubectl apply -f k8s/weather-api/namespace.yaml
kubectl apply -f k8s/weather-api/rbac.yaml
kubectl apply -f k8s/weather-api/networkpolicy.yaml
```
3. Apply logging stack (if not using Helm chart):
```bash
kubectl apply -f k8s/logging/
```
4. Deploy weather API:
```bash
kubectl apply -f k8s/weather-api/configmap.yaml
kubectl apply -f k8s/weather-api/secret.yaml
kubectl apply -f k8s/weather-api/serviceaccount.yaml
kubectl apply -f k8s/weather-api/service.yaml
kubectl apply -f k8s/weather-api/deployment.yaml
kubectl apply -f k8s/weather-api/hpa.yaml
kubectl apply -f k8s/weather-api/ingress.yaml
```

#### DNS Configuration
- Create DNS records pointing to API Gateway custom domain or NLB, depending on entry.
- For ingress, use an A/ALIAS to the NLB hostname.

#### SSL Certificates
- Use ACM certificates in the region of your NLB/API Gateway.
- Annotate ingress Service/Ingress with certificate ARNs.

#### Monitoring
- CloudWatch Container Insights via Helm chart.
- Fluent Bit DaemonSet or Helm chart shipping logs to CloudWatch.
- Alarms via SNS: CPU, memory, pod restarts, latency.

