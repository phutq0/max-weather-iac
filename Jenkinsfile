pipeline {
  agent any

  options {
    ansiColor('xterm')
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
    skipDefaultCheckout(true)
  }

  parameters {
    string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Docker image tag to build/deploy')
    choice(name: 'DEPLOY_ENV', choices: ['staging', 'production'], description: 'Target environment')
    booleanParam(name: 'RUN_SONARQUBE', defaultValue: false, description: 'Run SonarQube analysis & quality gate')
  }

  environment {
    AWS_REGION = 'us-east-1'
    ECR_ACCOUNT_ID = credentials('ecr-account-id')
    ECR_REPO = "${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/max-weather-dev"
    GIT_CREDENTIALS_ID = 'scm-creds'
    AWS_CREDENTIALS_ID = 'aws-creds'
    SLACK_CHANNEL = '#ci-cd'
    KUBE_CONTEXT_STAGING = 'arn:aws:eks:us-east-1:123456789012:cluster/staging'
    KUBE_CONTEXT_PRODUCTION = 'arn:aws:eks:us-east-1:123456789012:cluster/production'
    APP_NAME = 'weather-api'
    K8S_DIR = 'k8s/weather-api'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], userRemoteConfigs: [[credentialsId: env.GIT_CREDENTIALS_ID, url: scm.getUserRemoteConfigs()[0].getUrl()]])
      }
    }

    stage('Build') {
      steps {
        sh 'echo "No app build configured in this repo. Skipping."'
      }
    }

    stage('Test') {
      steps {
        sh 'echo "Run unit/integration tests here"'
      }
    }

    stage('SonarQube (optional)') {
      when { expression { return params.RUN_SONARQUBE } }
      steps {
        withSonarQubeEnv('sonarqube') {
          sh 'echo "sonar-scanner -Dsonar.projectKey=weather -Dsonar.sources=."'
        }
      }
    }

    stage('Docker Build & Push to ECR') {
      steps {
        withAWS(credentials: env.AWS_CREDENTIALS_ID, region: env.AWS_REGION) {
          sh '''
            aws ecr describe-repositories --repository-names weather-api >/dev/null 2>&1 || \
              aws ecr create-repository --repository-name weather-api >/dev/null
            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
            docker build -t ${ECR_REPO}:${IMAGE_TAG} .
            docker push ${ECR_REPO}:${IMAGE_TAG}
          '''
        }
      }
    }

    stage('Deploy to Staging (Blue-Green)') {
      when { expression { return params.DEPLOY_ENV == 'staging' } }
      steps {
        withAWS(credentials: env.AWS_CREDENTIALS_ID, region: env.AWS_REGION) {
          sh '''
            set -euo pipefail
            # Set kube context (eksctl or aws eks update-kubeconfig must be pre-configured on agent)
            aws eks update-kubeconfig --name staging --region ${AWS_REGION}

            NAMESPACE=staging
            COLOR_CUR=$(kubectl -n ${NAMESPACE} get svc ${APP_NAME} -o jsonpath='{.spec.selector.color}' 2>/dev/null || true)
            if [ "$COLOR_CUR" = "blue" ]; then NEXT_COLOR=green; else NEXT_COLOR=blue; fi

            kubectl -n ${NAMESPACE} apply -f ${K8S_DIR}/configmap.yaml
            kubectl -n ${NAMESPACE} apply -f ${K8S_DIR}/secret.yaml
            kubectl -n ${NAMESPACE} apply -f ${K8S_DIR}/serviceaccount.yaml
            kubectl -n ${NAMESPACE} apply -f ${K8S_DIR}/service.yaml

            # Render a color-specific deployment from template by patching labels/selector
            DEPLOY_NAME=${APP_NAME}-${NEXT_COLOR}
            kubectl -n ${NAMESPACE} get deploy ${DEPLOY_NAME} >/dev/null 2>&1 || \
              kubectl -n ${NAMESPACE} create deploy ${DEPLOY_NAME} --image=${ECR_REPO}:${IMAGE_TAG}

            kubectl -n ${NAMESPACE} set image deployment/${DEPLOY_NAME} ${APP_NAME}=${ECR_REPO}:${IMAGE_TAG} --record=true || true
            kubectl -n ${NAMESPACE} label deployment ${DEPLOY_NAME} app=${APP_NAME} color=${NEXT_COLOR} --overwrite

            # Wait for rollout
            kubectl -n ${NAMESPACE} rollout status deploy/${DEPLOY_NAME} --timeout=5m

            # Switch service selector to new color
            kubectl -n ${NAMESPACE} patch svc ${APP_NAME} -p "{\"spec\":{\"selector\":{\"app\":\"${APP_NAME}\",\"color\":\"${NEXT_COLOR}\"}}}"
          '''
        }
      }
    }

    stage('Approval') {
      when { expression { return params.DEPLOY_ENV == 'production' } }
      steps {
        timeout(time: 2, unit: 'HOURS') {
          input message: 'Deploy to Production?', ok: 'Deploy'
        }
      }
    }

    stage('Deploy to Production (Blue-Green)') {
      when { expression { return params.DEPLOY_ENV == 'production' } }
      steps {
        withAWS(credentials: env.AWS_CREDENTIALS_ID, region: env.AWS_REGION) {
          sh '''
            set -euo pipefail
            aws eks update-kubeconfig --name production --region ${AWS_REGION}

            NAMESPACE=production
            COLOR_CUR=$(kubectl -n ${NAMESPACE} get svc ${APP_NAME} -o jsonpath='{.spec.selector.color}' 2>/dev/null || true)
            if [ "$COLOR_CUR" = "blue" ]; then NEXT_COLOR=green; else NEXT_COLOR=blue; fi

            kubectl -n ${NAMESPACE} apply -f ${K8S_DIR}/configmap.yaml
            kubectl -n ${NAMESPACE} apply -f ${K8S_DIR}/secret.yaml
            kubectl -n ${NAMESPACE} apply -f ${K8S_DIR}/serviceaccount.yaml
            kubectl -n ${NAMESPACE} apply -f ${K8S_DIR}/service.yaml

            DEPLOY_NAME=${APP_NAME}-${NEXT_COLOR}
            kubectl -n ${NAMESPACE} get deploy ${DEPLOY_NAME} >/dev/null 2>&1 || \
              kubectl -n ${NAMESPACE} create deploy ${DEPLOY_NAME} --image=${ECR_REPO}:${IMAGE_TAG}

            kubectl -n ${NAMESPACE} set image deployment/${DEPLOY_NAME} ${APP_NAME}=${ECR_REPO}:${IMAGE_TAG} --record=true || true
            kubectl -n ${NAMESPACE} label deployment ${DEPLOY_NAME} app=${APP_NAME} color=${NEXT_COLOR} --overwrite

            kubectl -n ${NAMESPACE} rollout status deploy/${DEPLOY_NAME} --timeout=5m

            kubectl -n ${NAMESPACE} patch svc ${APP_NAME} -p "{\"spec\":{\"selector\":{\"app\":\"${APP_NAME}\",\"color\":\"${NEXT_COLOR}\"}}}"
          '''
        }
      }
    }
  }

  post {
    success {
      slackSend(channel: env.SLACK_CHANNEL, color: '#2eb886', message: "${env.JOB_NAME} #${env.BUILD_NUMBER} succeeded. ENV=${params.DEPLOY_ENV} TAG=${params.IMAGE_TAG}")
    }
    failure {
      script {
        // Attempt rollback if deployment failed after service switch
        withAWS(credentials: env.AWS_CREDENTIALS_ID, region: env.AWS_REGION) {
          sh '''
            set +e
            if [ "${DEPLOY_ENV}" = "staging" ]; then NS=staging; else NS=production; fi
            aws eks update-kubeconfig --name ${NS} --region ${AWS_REGION}
            CUR=$(kubectl -n ${NS} get svc ${APP_NAME} -o jsonpath='{.spec.selector.color}' 2>/dev/null)
            if [ "$CUR" = "blue" ]; then PREV=green; else PREV=blue; fi
            # Switch back if previous exists
            kubectl -n ${NS} get deploy ${APP_NAME}-${PREV} >/dev/null 2>&1 && \
              kubectl -n ${NS} patch svc ${APP_NAME} -p "{\"spec\":{\"selector\":{\"app\":\"${APP_NAME}\",\"color\":\"${PREV}\"}}}"
          '''
        }
      }
      slackSend(channel: env.SLACK_CHANNEL, color: '#a30200', message: "${env.JOB_NAME} #${env.BUILD_NUMBER} FAILED. ENV=${params.DEPLOY_ENV} TAG=${params.IMAGE_TAG}")
    }
    always {
      echo 'Pipeline completed.'
    }
  }
}

