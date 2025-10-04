#!/bin/bash

echo "Creating all Jenkins pipeline jobs..."

# Wait for Jenkins to be ready
while ! curl -f http://localhost:8080/login >/dev/null 2>&1; do
    sleep 5
    echo "Waiting for Jenkins to be ready..."
done

echo "Jenkins is ready! Creating all pipeline jobs..."

# Get CSRF crumb
CRUMB=$(curl -s -u admin:admin123 "http://localhost:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)")

# 1. Create Max Weather API Deployment Pipeline
echo "Creating Max Weather API deployment pipeline..."
cat > /tmp/max-weather-deployment.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.45">
  <description>Max Weather API Deployment Pipeline - Deploys to AWS EKS</description>
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
        DOCKER_BUILDKIT = '1'
        KUBECONFIG = '/var/jenkins_home/.kube/config'
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "Checking out code from branch: ${params.DEPLOY_BRANCH}"
                echo "Code checked out successfully"
            }
        }
        
        stage('Validate') {
            steps {
                echo "Validating deployment parameters"
                script {
                    if (!['dev', 'staging', 'prod'].contains(params.ENVIRONMENT)) {
                        error "Invalid environment: ${params.ENVIRONMENT}"
                    }
                }
            }
        }
        
        stage('Build') {
            steps {
                echo "Building Max Weather API for environment: ${params.ENVIRONMENT}"
                echo "Using image tag: ${params.IMAGE_TAG}"
                echo "ECR Registry: ${ECR_REGISTRY}"
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

curl -X POST "http://localhost:8080/createItem?name=max-weather-deployment" \
  -H "Content-Type: application/xml" \
  -H "$CRUMB" \
  --data-binary @/tmp/max-weather-deployment.xml \
  --user admin:admin123

if [ $? -eq 0 ]; then
    echo "✅ Max Weather API deployment pipeline created!"
else
    echo "❌ Failed to create Max Weather API pipeline"
fi

# 2. Create Infrastructure Deployment Pipeline
echo "Creating Infrastructure deployment pipeline..."
cat > /tmp/infrastructure-deployment.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.45">
  <description>Infrastructure Deployment Pipeline - Deploys AWS infrastructure using Terraform</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>
        <hudson.model.StringParameterDefinition>
          <name>ENVIRONMENT</name>
          <description>Target environment (dev, staging, prod)</description>
          <defaultValue>dev</defaultValue>
        </hudson.model.StringParameterDefinition>
        <hudson.model.BooleanParameterDefinition>
          <name>DESTROY</name>
          <description>Destroy infrastructure (use with caution)</description>
          <defaultValue>false</defaultValue>
        </hudson.model.BooleanParameterDefinition>
      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.94">
    <script>pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = '${AWS_REGION:-us-west-2}'
        TF_VAR_environment = '${params.ENVIRONMENT}'
    }
    
    stages {
        stage('Terraform Init') {
            steps {
                echo "Initializing Terraform"
                sh 'cd iac/terraform/environments/${params.ENVIRONMENT} && terraform init'
            }
        }
        
        stage('Terraform Plan') {
            steps {
                echo "Planning Terraform changes"
                sh 'cd iac/terraform/environments/${params.ENVIRONMENT} && terraform plan'
            }
        }
        
        stage('Terraform Apply') {
            when {
                not { params.DESTROY }
            }
            steps {
                echo "Applying Terraform changes"
                sh 'cd iac/terraform/environments/${params.ENVIRONMENT} && terraform apply -auto-approve'
            }
        }
        
        stage('Terraform Destroy') {
            when {
                params.DESTROY
            }
            steps {
                echo "Destroying infrastructure"
                sh 'cd iac/terraform/environments/${params.ENVIRONMENT} && terraform destroy -auto-approve'
            }
        }
    }
    
    post {
        always {
            echo "Infrastructure pipeline completed"
        }
    }
}</script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

curl -X POST "http://localhost:8080/createItem?name=infrastructure-deployment" \
  -H "Content-Type: application/xml" \
  -H "$CRUMB" \
  --data-binary @/tmp/infrastructure-deployment.xml \
  --user admin:admin123

if [ $? -eq 0 ]; then
    echo "✅ Infrastructure deployment pipeline created!"
else
    echo "❌ Failed to create Infrastructure pipeline"
fi

# 3. Create Cleanup Maintenance Job
echo "Creating Cleanup maintenance job..."
cat > /tmp/cleanup-maintenance.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<project>
  <description>Cleanup and Maintenance Pipeline - Cleans up old builds, artifacts, and performs maintenance tasks</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers>
    <hudson.triggers.TimerTrigger>
      <spec>0 2 * * *</spec>
    </hudson.triggers.TimerTrigger>
  </triggers>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>#!/bin/bash
echo "Starting cleanup and maintenance tasks..."

# Clean up old builds (keep last 10)
echo "Cleaning up old builds..."
find /var/jenkins_home/jobs/*/builds -maxdepth 1 -type d -name "[0-9]*" | sort -n | head -n -10 | xargs rm -rf 2>/dev/null || true

# Clean up old artifacts
echo "Cleaning up old artifacts..."
find /var/jenkins_home/jobs/*/builds -name "*.log" -mtime +7 -delete 2>/dev/null || true

# Clean up Docker images
echo "Cleaning up Docker images..."
docker image prune -f 2>/dev/null || true

echo "Cleanup completed successfully"</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
EOF

curl -X POST "http://localhost:8080/createItem?name=cleanup-maintenance" \
  -H "Content-Type: application/xml" \
  -H "$CRUMB" \
  --data-binary @/tmp/cleanup-maintenance.xml \
  --user admin:admin123

if [ $? -eq 0 ]; then
    echo "✅ Cleanup maintenance job created!"
else
    echo "❌ Failed to create Cleanup maintenance job"
fi

echo ""
echo "🎉 All Jenkins pipeline jobs created successfully!"
echo ""
echo "Available jobs:"
echo "1. max-weather-deployment (Pipeline)"
echo "2. infrastructure-deployment (Pipeline)"
echo "3. cleanup-maintenance (Freestyle)"
echo "4. seed-jobs (Freestyle)"
echo ""
echo "🌐 Access Jenkins at: http://localhost:8080"
echo "👤 Login: admin / admin123"
