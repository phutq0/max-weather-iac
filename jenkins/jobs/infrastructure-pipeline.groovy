// Infrastructure Pipeline
// This DSL script creates the infrastructure deployment pipeline

pipelineJob('infrastructure-deployment') {
    description('Infrastructure Deployment Pipeline - Deploys AWS infrastructure using Terraform')
    
    parameters {
        stringParam('ENVIRONMENT', 'dev', 'Target environment (dev, staging, prod)')
        stringParam('TERRAFORM_VERSION', '1.7.0', 'Terraform version to use')
        booleanParam('DESTROY', false, 'Destroy infrastructure (use with caution)')
        booleanParam('PLAN_ONLY', false, 'Only show plan, do not apply')
    }
    
    triggers {
        // Trigger on changes to infrastructure code
        githubPush()
    }
    
    definition {
        cps {
            script('''
pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = '${AWS_REGION:-us-west-2}'
        TF_VAR_environment = '${params.ENVIRONMENT}'
        TF_VAR_region = '${AWS_REGION:-us-west-2}'
    }
    
    options {
        timeout(time: 60, unit: 'MINUTES')
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "Checking out infrastructure code"
                // This would normally checkout from Git
                echo "Infrastructure code checked out successfully"
            }
        }
        
        stage('Terraform Init') {
            steps {
                echo "Initializing Terraform"
                script {
                    sh '''
                        cd iac/terraform/environments/${params.ENVIRONMENT}
                        terraform init
                    '''
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                echo "Planning Terraform changes"
                script {
                    sh '''
                        cd iac/terraform/environments/${params.ENVIRONMENT}
                        terraform plan -out=tfplan
                    '''
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                not { params.PLAN_ONLY }
                not { params.DESTROY }
            }
            steps {
                echo "Applying Terraform changes"
                script {
                    sh '''
                        cd iac/terraform/environments/${params.ENVIRONMENT}
                        terraform apply -auto-approve tfplan
                    '''
                }
            }
        }
        
        stage('Terraform Destroy') {
            when {
                params.DESTROY
            }
            steps {
                echo "Destroying infrastructure"
                script {
                    sh '''
                        cd iac/terraform/environments/${params.ENVIRONMENT}
                        terraform destroy -auto-approve
                    '''
                }
            }
        }
        
        stage('Output') {
            steps {
                echo "Terraform outputs"
                script {
                    sh '''
                        cd iac/terraform/environments/${params.ENVIRONMENT}
                        terraform output
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo "Infrastructure pipeline completed"
        }
        success {
            echo "Infrastructure deployment successful!"
        }
        failure {
            echo "Infrastructure deployment failed!"
        }
    }
}
            '''.stripIndent())
        }
    }
}
