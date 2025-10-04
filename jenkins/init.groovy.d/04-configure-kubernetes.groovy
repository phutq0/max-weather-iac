import jenkins.model.Jenkins
import jenkins.model.JenkinsLocationConfiguration

def instance = Jenkins.getInstance()

// Configure Jenkins URL
def locationConfig = JenkinsLocationConfiguration.get()
locationConfig.setUrl("http://localhost:8080/")
locationConfig.setAdminAddress("admin@max-weather.com")

// Set up global environment variables
try {
    def globalNodeProperties = instance.getGlobalNodeProperties()
    def envVarsNodeProperty = globalNodeProperties.getAll(hudson.slaves.EnvironmentVariablesNodeProperty.class)
    
    if (envVarsNodeProperty.isEmpty()) {
        envVarsNodeProperty = new hudson.slaves.EnvironmentVariablesNodeProperty()
        globalNodeProperties.add(envVarsNodeProperty)
    }
    
    def envVars = envVarsNodeProperty[0].getEnvVars()
    envVars.put("KUBECONFIG", "/var/jenkins_home/.kube/config")
    envVars.put("AWS_DEFAULT_REGION", System.getenv("AWS_REGION") ?: "us-west-2")
    envVars.put("DOCKER_BUILDKIT", "1")
    
    println "Environment variables configured"
} catch (Exception e) {
    println "Could not configure environment variables: ${e.message}"
}

instance.save()
println "Kubernetes and environment configuration completed"
