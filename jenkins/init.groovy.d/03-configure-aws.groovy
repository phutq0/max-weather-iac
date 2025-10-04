import jenkins.model.Jenkins
import com.cloudbees.plugins.credentials.CredentialsScope
import com.cloudbees.plugins.credentials.SystemCredentialsProvider
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl

def instance = Jenkins.getInstance()

try {
    def credentialsStore = SystemCredentialsProvider.getInstance().getStore()
    
    // Add AWS credentials if environment variables are set
    def awsAccessKey = System.getenv("AWS_ACCESS_KEY_ID")
    def awsSecretKey = System.getenv("AWS_SECRET_ACCESS_KEY")
    
    if (awsAccessKey && awsSecretKey) {
        def awsCredentials = new UsernamePasswordCredentialsImpl(
            CredentialsScope.GLOBAL,
            "aws-credentials",
            "AWS Credentials for Max Weather API",
            awsAccessKey,
            awsSecretKey
        )
        
        credentialsStore.addCredentials(Domain.global(), awsCredentials)
        println "AWS credentials added"
    } else {
        println "AWS credentials not found in environment variables"
    }
    
    // Add GitHub token if available
    def githubToken = System.getenv("GITHUB_TOKEN")
    if (githubToken) {
        def githubCredentials = new UsernamePasswordCredentialsImpl(
            CredentialsScope.GLOBAL,
            "github-token",
            "GitHub Personal Access Token",
            "github",
            githubToken
        )
        
        credentialsStore.addCredentials(Domain.global(), githubCredentials)
        println "GitHub credentials added"
    }
    
    instance.save()
    println "Credentials configuration completed"
} catch (Exception e) {
    println "Could not configure credentials: ${e.message}"
}
