# Deployment Guide

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.5.0
- kubectl
- Docker (for local testing)
- Helm (for ingress-nginx installation)

## Infrastructure Deployment

### 1. Configure Terraform Backend

Update the S3 backend configuration in `terraform/main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "max-weather/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "your-terraform-lock-table"
    encrypt        = true
  }
}
```

### 2. Deploy to Staging

```bash
cd terraform/environments/staging
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### 3. Deploy to Production

```bash
cd terraform/environments/production
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Application Deployment

### 1. Configure kubectl

```bash
# For staging
aws eks update-kubeconfig --region us-east-1 --name max-weather-staging

# For production
aws eks update-kubeconfig --region us-east-1 --name max-weather-production
```

### 2. Install NGINX Ingress Controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --values k8s/ingress-nginx/values.yaml
```

### 3. Deploy Weather API

```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/weather-api/configmap.yaml
kubectl apply -f k8s/weather-api/secret.yaml
kubectl apply -f k8s/weather-api/serviceaccount.yaml
kubectl apply -f k8s/weather-api/service.yaml
kubectl apply -f k8s/weather-api/deployment.yaml
kubectl apply -f k8s/weather-api/hpa.yaml
kubectl apply -f k8s/weather-api/ingress.yaml
```

### 4. Verify Deployment

```bash
# Check pods
kubectl get pods

# Check services
kubectl get svc

# Check ingress
kubectl get ingress

# Check HPA
kubectl get hpa
```

## Configuration

### Environment Variables

Update `k8s/weather-api/secret.yaml` with your values:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: weather-api-secrets
type: Opaque
stringData:
  OPENWEATHER_API_KEY: "your-openweather-api-key"
  OTHER_SECRET: "your-other-secret"
```

### API Gateway Configuration

1. **Update Lambda Authorizer Environment**:
   - Set OAuth2 issuer URL
   - Configure client credentials
   - Update introspection URL

2. **Configure API Gateway Backend**:
   - Update `terraform/modules/api-gateway/main.tf` with your NLB domain
   - Set ACM certificate ARN for TLS

### DNS Configuration

1. **Create DNS records** pointing to:
   - API Gateway custom domain (if using)
   - NLB hostname for direct ingress access

2. **Update ingress host** in `k8s/weather-api/ingress.yaml`:
   ```yaml
   spec:
     tls:
     - hosts:
       - weather.yourdomain.com
     rules:
     - host: weather.yourdomain.com
   ```

## Testing

### 1. Local Testing

```bash
# Build and run locally
docker build -t weather-api -f docker/Dockerfile .
docker run -p 3000:3000 -e OPENWEATHER_API_KEY=your-key weather-api

# Test health endpoint
curl http://localhost:3000/health

# Test weather endpoint
curl "http://localhost:3000/api/v1/weather?q=London"
```

### 2. Postman Testing

1. Import `postman/Max_Weather_API.postman_collection.json`
2. Import `postman/Max_Weather_API.postman_environment.json`
3. Update environment variables:
   - `base_url`: Your API Gateway or ingress URL
   - `api_key`: Your API Gateway key
   - `oauth_token_url`: Your OAuth2 token endpoint
   - `client_id` and `client_secret`: OAuth2 credentials

### 3. Load Testing

```bash
# Generate load to test HPA
for i in {1..100}; do
  curl "https://your-api-url/api/v1/weather?q=London" &
done
wait

# Watch HPA scale
kubectl get hpa weather-api -w
```

## Monitoring

### CloudWatch Logs

- **Application logs**: `/aws/eks/<cluster>/applications`
- **Control plane logs**: `/aws/eks/<cluster>/cluster`
- **API Gateway logs**: `/aws/apigateway/<api-name>`

### Alarms

Monitor these CloudWatch alarms:
- CPU utilization > 80%
- Memory utilization > 85%
- Pod restart rate
- API response time > 1000ms

### SNS Notifications

Configure email subscriptions in the CloudWatch module for alert notifications.

## Troubleshooting

### Common Issues

1. **Pods not starting**:
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

2. **Ingress not accessible**:
   ```bash
   kubectl describe ingress weather-api
   kubectl get svc -n ingress-nginx
   ```

3. **HPA not scaling**:
   ```bash
   kubectl describe hpa weather-api
   kubectl top pods
   ```

4. **API Gateway 401/403**:
   - Check Lambda authorizer logs
   - Verify OAuth2 configuration
   - Test with valid token

### Debug Commands

```bash
# Check all resources
kubectl get all

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check logs
kubectl logs -f deploy/weather-api

# Check ingress controller
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

## Cleanup

### Destroy Infrastructure

```bash
# Destroy production
cd terraform/environments/production
terraform destroy -var-file=terraform.tfvars

# Destroy staging
cd terraform/environments/staging
terraform destroy -var-file=terraform.tfvars
```

### Clean Kubernetes Resources

```bash
kubectl delete -f k8s/weather-api/
helm uninstall ingress-nginx -n ingress-nginx
```