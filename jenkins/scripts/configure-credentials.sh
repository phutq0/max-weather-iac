#!/bin/bash

# Configure Jenkins credentials via CLI
JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_PASSWORD="${JENKINS_ADMIN_PASSWORD:-admin123}"

echo "Configuring Jenkins credentials..."

# Wait for Jenkins to be ready
./wait-for-jenkins.sh

# Create AWS credentials
java -jar /usr/share/jenkins/jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
    create-credentials-by-xml system::system::jenkins _ < /dev/stdin <<EOF
<com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>aws-credentials</id>
  <description>AWS Credentials for Max Weather API</description>
  <accessKey>${AWS_ACCESS_KEY_ID}</accessKey>
  <secretKey>${AWS_SECRET_ACCESS_KEY}</secretKey>
  <iamRoleArn></iamRoleArn>
  <iamMfaSerialNumber></iamMfaSerialNumber>
</com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl>
EOF

# Create GitHub credentials if token is provided
if [ -n "$GITHUB_TOKEN" ]; then
    java -jar /usr/share/jenkins/jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
        create-credentials-by-xml system::system::jenkins _ < /dev/stdin <<EOF
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>github-token</id>
  <description>GitHub Personal Access Token</description>
  <username>github</username>
  <password>${GITHUB_TOKEN}</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
fi

echo "Credentials configuration completed"
