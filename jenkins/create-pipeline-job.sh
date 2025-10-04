#!/bin/bash

echo "Creating Max Weather API deployment pipeline..."

# Wait for Jenkins to be ready
while ! curl -f http://localhost:8080/login >/dev/null 2>&1; do
    sleep 5
    echo "Waiting for Jenkins to be ready..."
done

echo "Jenkins is ready! Creating pipeline job..."

# Create the pipeline job XML
cat > /tmp/max-weather-pipeline.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.45">
  <description>Max Weather API Deployment Pipeline</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>
        <hudson.model.StringParameterDefinition>
          <name>ENVIRONMENT</name>
          <description>Target environment (dev, staging, prod)</description>
          <defaultValue>dev</defaultValue>
        </hudson.model.StringParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>IMAGE_TAG</name>
          <description>Docker image tag to deploy</description>
          <defaultValue>latest</defaultValue>
        </hudson.model.StringParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>DEPLOY_BRANCH</name>
          <description>Git branch to deploy</description>
          <defaultValue>main</defaultValue>
        </hudson.model.StringParameterDefinition>
      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.94">
    <script>pipeline {
    agent any
    
    parameters {
        string(name: 'ENVIRONMENT', defaultValue: 'dev', description: 'Target environment')
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Docker image tag')
        string(name: 'DEPLOY_BRANCH', defaultValue: 'main', description: 'Git branch')
    }
    
    environment {
        AWS_DEFAULT_REGION = '${AWS_REGION:-us-west-2}'
        ECR_REGISTRY = '${ECR_REGISTRY}'
        EKS_CLUSTER_NAME = '${EKS_CLUSTER_NAME}'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "Checking out code from branch: ${params.DEPLOY_BRANCH}"
                // This would normally checkout from Git
                echo "Code checked out successfully"
            }
        }
        
        stage('Build') {
            steps {
                echo "Building Max Weather API for environment: ${params.ENVIRONMENT}"
                echo "Using image tag: ${params.IMAGE_TAG}"
                echo "ECR Registry: ${ECR_REGISTRY}"
                // This would normally build the Docker image
                echo "Build completed successfully"
            }
        }
        
        stage('Deploy') {
            steps {
                echo "Deploying to ${params.ENVIRONMENT} environment"
                echo "EKS Cluster: ${EKS_CLUSTER_NAME}"
                echo "Deployment completed successfully"
            }
        }
    }
    
    post {
        always {
            echo "Pipeline execution completed"
        }
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Deployment failed!"
        }
    }
}</script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

# Get CSRF crumb for API calls
CRUMB=$(curl -s -u admin:admin123 "http://localhost:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)")

# Create the pipeline job
curl -X POST "http://localhost:8080/createItem?name=max-weather-deployment" \
  -H "Content-Type: application/xml" \
  -H "$CRUMB" \
  --data-binary @/tmp/max-weather-pipeline.xml \
  --user admin:admin123

if [ $? -eq 0 ]; then
    echo "✅ Max Weather API deployment pipeline created successfully!"
    echo "🌐 Access Jenkins at: http://localhost:8080"
    echo "👤 Login: admin / admin123"
    echo "📋 Job: max-weather-deployment"
else
    echo "❌ Failed to create pipeline job"
    exit 1
fi

echo "🎉 Jenkins setup complete with job bootstrapping!"
