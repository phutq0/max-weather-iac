#!/bin/bash

# Deploy weather API to dev environment using Kustomize
set -e

echo "🚀 Deploying Weather API to DEV environment..."

# Check if kubectl is configured
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ kubectl is not configured or cluster is not accessible"
    echo "Please run: aws eks update-kubeconfig --region ap-southeast-2 --name max-weather-dev"
    exit 1
fi

# Create namespace if it doesn't exist
echo "📦 Creating dev namespace..."
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

# Deploy weather API using Kustomize
echo "🌤️  Deploying weather API to dev environment..."
kubectl apply -k overlays/weather-api/dev

# Wait for deployment to be ready
echo "⏳ Waiting for weather API to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/dev-weather-api -n dev

# Get the LoadBalancer endpoint
# echo "🔍 Getting LoadBalancer endpoint..."
# LB_ENDPOINT=$(kubectl get svc nginx-ingress-ingress-nginx-controller -n nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# if [ -n "$LB_ENDPOINT" ]; then
#     echo "✅ Weather API deployed successfully to DEV!"
#     echo "🌐 LoadBalancer endpoint: $LB_ENDPOINT"
#     echo "🔗 Test URL: http://$LB_ENDPOINT/api/v1/weather"
# else
#     echo "⚠️  LoadBalancer endpoint not ready yet. Check with:"
#     echo "kubectl get svc nginx-ingress-ingress-nginx-controller -n nginx"
# fi

echo "📊 Deployment status:"
kubectl get pods -l app=weather-api -n dev
kubectl get svc dev-weather-api -n dev
kubectl get ingress dev-weather-api -n dev