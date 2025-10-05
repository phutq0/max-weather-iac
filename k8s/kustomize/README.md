# Weather API Kubernetes Manifests

This directory contains Kubernetes manifests for the Weather API application, organized using Kustomize for multi-environment deployment.

## Directory Structure

```
k8s/kustomize
├── base/                          # Base manifests (environment-agnostic)
│   ├── kustomization.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── serviceaccount.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── hpa.yaml
├── overlays/                      # Environment-specific overlays
│   ├── dev/                       # Development environment
│   │   ├── kustomization.yaml
│   │   ├── deployment-patch.yaml
│   │   ├── configmap-patch.yaml
│   │   └── secret-patch.yaml
│   ├── staging/                   # Staging environment
│   │   ├── kustomization.yaml
│   │   ├── deployment-patch.yaml
│   │   ├── configmap-patch.yaml
│   │   └── secret-patch.yaml
│   └── production/                # Production environment
│       ├── kustomization.yaml
│       ├── deployment-patch.yaml
│       ├── configmap-patch.yaml
│       └── secret-patch.yaml
├── deploy-dev.sh                  # Dev deployment script
├── deploy-staging.sh              # Staging deployment script
├── deploy-production.sh           # Production deployment script
└── README.md                      # This file
```

## Environment Configurations

### Development
- **Namespace**: `dev`
- **Replicas**: 1
- **Resources**: 100m CPU, 64Mi memory
- **Image**: `max-weather-dev:latest`
- **Log Level**: debug
- **Cache TTL**: 60 seconds

### Staging
- **Namespace**: `staging`
- **Replicas**: 2
- **Resources**: 250m CPU, 128Mi memory
- **Image**: `max-weather-staging:latest`
- **Log Level**: info
- **Cache TTL**: 300 seconds

### Production
- **Namespace**: `production`
- **Replicas**: 3
- **Resources**: 500m CPU, 256Mi memory
- **Image**: `max-weather-prod:latest`
- **Log Level**: warn
- **Cache TTL**: 600 seconds

## Deployment Commands

### Development
```bash
# Deploy to dev environment
./deploy-dev.sh

# Or manually with kubectl
kubectl apply -k overlays/dev
```

### Staging
```bash
# Deploy to staging environment
./deploy-staging.sh

# Or manually with kubectl
kubectl apply -k overlays/staging
```

### Production
```bash
# Deploy to production environment
./deploy-production.sh

# Or manually with kubectl
kubectl apply -k overlays/production
```

## Kustomize Benefits

1. **Environment Separation**: Each environment has its own namespace and configuration
2. **Resource Management**: Different resource limits per environment
3. **Image Management**: Environment-specific container images
4. **Configuration Override**: Environment-specific ConfigMaps and Secrets
5. **Reusability**: Base manifests are shared across environments
6. **Maintainability**: Changes to base manifests apply to all environments

## Customization

### Adding New Environment
1. Create new directory under `overlays/`
2. Copy existing overlay structure
3. Modify `kustomization.yaml` and patch files
4. Create deployment script

### Modifying Base Manifests
1. Edit files in `base/` directory
2. Changes will apply to all environments
3. Test with `kubectl apply -k overlays/dev`

### Environment-Specific Changes
1. Edit patch files in respective overlay directory
2. Use `patchesStrategicMerge` for complex changes
3. Use `patchesJson6902` for precise modifications

## Troubleshooting

### View Generated Manifests
```bash
# Preview what will be applied
kubectl apply -k overlays/dev --dry-run=client -o yaml

# View specific resource
kubectl get -k overlays/dev deployment
```

### Check Deployment Status
```bash
# Check pods
kubectl get pods -l app=weather-api -n dev

# Check services
kubectl get svc -n dev

# Check ingress
kubectl get ingress -n dev
```

### View Logs
```bash
# Application logs
kubectl logs -l app=weather-api -n dev

# Follow logs
kubectl logs -f -l app=weather-api -n dev
```
