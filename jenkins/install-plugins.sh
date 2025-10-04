#!/bin/bash

# Wait for Jenkins to be ready
echo "Waiting for Jenkins to be ready..."
while ! curl -f http://localhost:8080/login >/dev/null 2>&1; do
    sleep 5
    echo "Still waiting for Jenkins..."
done

echo "Jenkins is ready! Installing plugins..."

# Get Jenkins CLI
wget -O jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar

# Install essential plugins
java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin configuration-as-code job-dsl workflow-aggregator git timestamper ansicolor build-timeout credentials-binding

# Restart Jenkins to load plugins
java -jar jenkins-cli.jar -s http://localhost:8080 restart

echo "Plugins installed and Jenkins restarted!"
