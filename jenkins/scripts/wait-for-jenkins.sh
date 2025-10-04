#!/bin/bash

# Wait for Jenkins to be ready
echo "Waiting for Jenkins to be ready..."

JENKINS_URL="http://localhost:8080"
MAX_ATTEMPTS=30
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s -f "$JENKINS_URL/login" > /dev/null 2>&1; then
        echo "Jenkins is ready!"
        exit 0
    fi
    
    echo "Attempt $((ATTEMPT + 1))/$MAX_ATTEMPTS: Jenkins not ready yet..."
    sleep 10
    ATTEMPT=$((ATTEMPT + 1))
done

echo "Jenkins failed to start within expected time"
exit 1
