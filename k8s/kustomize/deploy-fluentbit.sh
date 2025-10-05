#!/bin/bash

# Deploy FluentBit to EKS cluster using Kustomize
set -e

ENVIRONMENT=${1:-dev}

echo "🚀 Deploying FluentBit to $ENVIRONMENT environment..."

# Check if kubectl is configured
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ kubectl is not configured or cluster is not accessible"
    echo "Please run: aws eks update-kubeconfig --region ap-southeast-2 --name max-weather-$ENVIRONMENT"
    exit 1
fi

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    echo "❌ Invalid environment. Use: dev, staging, or production"
    exit 1
fi

# Create namespace if it doesn't exist
echo "📦 Creating amazon-cloudwatch namespace..."
kubectl create namespace amazon-cloudwatch --dry-run=client -o yaml | kubectl apply -f -

# Deploy FluentBit using Kustomize
echo "📊 Deploying FluentBit to $ENVIRONMENT environment..."
kubectl apply -k overlays/fluentbit/$ENVIRONMENT

# Wait for FluentBit to be ready
echo "⏳ Waiting for FluentBit to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=fluent-bit -n amazon-cloudwatch --timeout=300s

echo "✅ FluentBit deployed successfully to $ENVIRONMENT!"
echo "📊 Deployment status:"
kubectl get pods -l app.kubernetes.io/name=fluent-bit -n amazon-cloudwatch
kubectl get configmap -n amazon-cloudwatch | grep fluent-bit

echo "🔍 Cluster info ConfigMap:"
kubectl get configmap ${ENVIRONMENT}-fluent-bit-cluster-info -n amazon-cloudwatch -o yaml
