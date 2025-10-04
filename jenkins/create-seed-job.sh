#!/bin/bash

# Wait for Jenkins to be ready
echo "Waiting for Jenkins to be ready..."
while ! curl -f http://localhost:8080/login >/dev/null 2>&1; do
    sleep 5
    echo "Still waiting for Jenkins..."
done

echo "Jenkins is ready! Creating seed job..."

# Create seed job XML
cat > /tmp/seed-job.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<project>
  <description>Seed job to create Max Weather API deployment pipeline</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>#!/bin/bash
echo "Creating Max Weather API deployment pipeline..."

# Create the pipeline job
cat > /tmp/max-weather-pipeline.xml << 'PIPELINE_EOF'
&lt;?xml version='1.1' encoding='UTF-8'?&gt;
&lt;flow-definition plugin="workflow-job@2.45"&gt;
  &lt;description&gt;Max Weather API Deployment Pipeline&lt;/description&gt;
  &lt;keepDependencies&gt;false&lt;/keepDependencies&gt;
  &lt;properties&gt;
    &lt;hudson.model.ParametersDefinitionProperty&gt;
      &lt;parameterDefinitions&gt;
        &lt;hudson.model.StringParameterDefinition&gt;
          &lt;name&gt;ENVIRONMENT&lt;/name&gt;
          &lt;description&gt;Target environment (dev, staging, prod)&lt;/description&gt;
          &lt;defaultValue&gt;dev&lt;/defaultValue&gt;
        &lt;/hudson.model.StringParameterDefinition&gt;
        &lt;hudson.model.StringParameterDefinition&gt;
          &lt;name&gt;IMAGE_TAG&lt;/name&gt;
          &lt;description&gt;Docker image tag to deploy&lt;/description&gt;
          &lt;defaultValue&gt;latest&lt;/defaultValue&gt;
        &lt;/hudson.model.StringParameterDefinition&gt;
        &lt;hudson.model.StringParameterDefinition&gt;
          &lt;name&gt;DEPLOY_BRANCH&lt;/name&gt;
          &lt;description&gt;Git branch to deploy&lt;/description&gt;
          &lt;defaultValue&gt;main&lt;/defaultValue&gt;
        &lt;/hudson.model.StringParameterDefinition&gt;
      &lt;/parameterDefinitions&gt;
    &lt;/hudson.model.ParametersDefinitionProperty&gt;
  &lt;/properties&gt;
  &lt;definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.94"&gt;
    &lt;scm class="hudson.plugins.git.GitSCM" plugin="git@4.11.3"&gt;
      &lt;configVersion&gt;2&lt;/configVersion&gt;
      &lt;userRemoteConfigs&gt;
        &lt;hudson.plugins.git.UserRemoteConfig&gt;
          &lt;url&gt;file:///var/jenkins_home/workspace/max-weather-iac&lt;/url&gt;
        &lt;/hudson.plugins.git.UserRemoteConfig&gt;
      &lt;/userRemoteConfigs&gt;
      &lt;branches&gt;
        &lt;hudson.plugins.git.BranchSpec&gt;
          &lt;name&gt;*/${DEPLOY_BRANCH}&lt;/name&gt;
        &lt;/hudson.plugins.git.BranchSpec&gt;
      &lt;/branches&gt;
      &lt;doGenerateSubmoduleConfigurations&gt;false&lt;/doGenerateSubmoduleConfigurations&gt;
      &lt;submoduleCfg class="list"/&gt;
      &lt;extensions/&gt;
    &lt;/scm&gt;
    &lt;scriptPath&gt;Jenkinsfile&lt;/scriptPath&gt;
    &lt;lightweight&gt;false&lt;/lightweight&gt;
  &lt;/definition&gt;
  &lt;triggers/&gt;
  &lt;disabled&gt;false&lt;/disabled&gt;
&lt;/flow-definition&gt;
PIPELINE_EOF

# Create the job via REST API
curl -X POST "http://localhost:8080/createItem?name=max-weather-deployment" \
  -H "Content-Type: application/xml" \
  --data-binary @/tmp/max-weather-pipeline.xml \
  --user admin:admin123

echo "Max Weather API deployment pipeline created!"
</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
EOF

# Create the seed job
curl -X POST "http://localhost:8080/createItem?name=seed-job" \
  -H "Content-Type: application/xml" \
  --data-binary @/tmp/seed-job.xml \
  --user admin:admin123

echo "Seed job created! Triggering it..."

# Trigger the seed job
curl -X POST "http://localhost:8080/job/seed-job/build" \
  --user admin:admin123

echo "Seed job triggered! Check Jenkins UI for progress."
