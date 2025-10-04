#!/bin/bash

echo "Setting up Jenkins jobs for Max Weather API..."

# Wait for Jenkins to be ready
while ! curl -f http://localhost:8080/login >/dev/null 2>&1; do
    sleep 5
    echo "Waiting for Jenkins to be ready..."
done

echo "Jenkins is ready! Setting up jobs..."

# Create a simple pipeline job XML
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
                // This would normally build the Docker image
                echo "Build completed successfully"
            }
        }
        
        stage('Deploy') {
            steps {
                echo "Deploying to ${params.ENVIRONMENT} environment"
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

echo "Max Weather API deployment pipeline configuration created!"
echo "Please manually create the job in Jenkins UI:"
echo "1. Go to http://localhost:8080"
echo "2. Login with admin/admin123"
echo "3. Click 'New Item'"
echo "4. Enter 'max-weather-deployment' as name"
echo "5. Select 'Pipeline'"
echo "6. Copy the configuration from /tmp/max-weather-pipeline.xml"
echo "7. Save and run the job"

echo "Job setup instructions provided!"
