#!/bin/bash

# Test FluentBit Kustomize configuration
set -e

ENVIRONMENT=${1:-dev}

echo "🧪 Testing FluentBit Kustomize configuration for $ENVIRONMENT environment..."

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    echo "❌ Invalid environment. Use: dev, staging, or production"
    exit 1
fi

# Test kustomize build
echo "🔍 Testing kustomize build..."
kustomize build overlays/fluentbit/$ENVIRONMENT > /tmp/fluentbit-$ENVIRONMENT.yaml

if [ $? -eq 0 ]; then
    echo "✅ Kustomize build successful!"
    echo "📄 Generated manifest saved to /tmp/fluentbit-$ENVIRONMENT.yaml"
    
    # Show some key information
    echo "📊 Generated resources:"
    grep -E "^kind:|^  name:" /tmp/fluentbit-$ENVIRONMENT.yaml | head -20
    
    echo "🔍 Cluster info ConfigMap content:"
    grep -A 10 "name: ${ENVIRONMENT}-fluent-bit-cluster-info" /tmp/fluentbit-$ENVIRONMENT.yaml || echo "ConfigMap not found in generated manifest"
    
else
    echo "❌ Kustomize build failed!"
    exit 1
fi
