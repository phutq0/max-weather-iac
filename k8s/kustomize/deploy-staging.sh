#!/bin/bash

# Deploy weather API to staging environment using Kustomize
set -e

echo "🚀 Deploying Weather API to STAGING environment..."

# Check if kubectl is configured
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ kubectl is not configured or cluster is not accessible"
    echo "Please run: aws eks update-kubeconfig --region ap-southeast-2 --name max-weather-staging"
    exit 1
fi

# Create namespace if it doesn't exist
echo "📦 Creating staging namespace..."
kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -

# Deploy weather API using Kustomize
echo "🌤️  Deploying weather API to staging environment..."
kubectl apply -k overlays/staging

# Wait for deployment to be ready
echo "⏳ Waiting for weather API to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/staging-weather-api -n staging

echo "✅ Weather API deployed successfully to STAGING!"
echo "📊 Deployment status:"
kubectl get pods -l app=weather-api -n staging
kubectl get svc staging-weather-api -n staging
kubectl get ingress staging-weather-api -n staging
