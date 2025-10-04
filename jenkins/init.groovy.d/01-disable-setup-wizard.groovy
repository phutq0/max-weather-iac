// Set system message and basic configuration
import jenkins.model.Jenkins

def instance = Jenkins.getInstance()

// Set system message
instance.setSystemMessage("Max Weather API - Jenkins CI/CD Pipeline\n\nThis Jenkins instance is configured for the Max Weather API deployment pipeline.")

// Set number of executors
instance.setNumExecutors(2)

// Set mode to NORMAL
instance.setMode(jenkins.model.Jenkins.Mode.NORMAL)

println "Jenkins basic configuration completed"
