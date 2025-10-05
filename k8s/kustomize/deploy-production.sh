#!/bin/bash

# Deploy weather API to production environment using Kustomize
set -e

echo "🚀 Deploying Weather API to PRODUCTION environment..."

# Check if kubectl is configured
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ kubectl is not configured or cluster is not accessible"
    echo "Please run: aws eks update-kubeconfig --region ap-southeast-2 --name max-weather-prod"
    exit 1
fi

# Create namespace if it doesn't exist
echo "📦 Creating production namespace..."
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -

# Deploy weather API using Kustomize
echo "🌤️  Deploying weather API to production environment..."
kubectl apply -k overlays/weather-api/production

# Wait for deployment to be ready
echo "⏳ Waiting for weather API to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prod-weather-api -n production

echo "✅ Weather API deployed successfully to PRODUCTION!"
echo "📊 Deployment status:"
kubectl get pods -l app=weather-api -n production
kubectl get svc prod-weather-api -n production
kubectl get ingress prod-weather-api -n production
