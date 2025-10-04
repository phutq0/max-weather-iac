import jenkins.model.Jenkins
import hudson.security.HudsonPrivateSecurityRealm
import hudson.security.FullControlOnceLoggedInAuthorizationStrategy
import hudson.security.csrf.DefaultCrumbIssuer
import jenkins.security.s2m.AdminWhitelistRule

def instance = Jenkins.getInstance()

// Create admin user if it doesn't exist
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def adminPassword = System.getenv("JENKINS_ADMIN_PASSWORD") ?: "admin123"
hudsonRealm.createAccount("admin", adminPassword)
instance.setSecurityRealm(hudsonRealm)

// Set authorization strategy
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

// Disable CSRF protection for easier API access
instance.setCrumbIssuer(null)

// Disable CLI over remoting (if available)
try {
    def cliDescriptor = instance.getDescriptor("jenkins.CLI")
    if (cliDescriptor != null) {
        cliDescriptor.setEnabled(false)
    }
} catch (Exception e) {
    println "Could not disable CLI: ${e.message}"
}

// Enable agent to master security subsystem (if available)
try {
    def adminWhitelistRule = instance.getInjector().getInstance(AdminWhitelistRule.class)
    if (adminWhitelistRule != null) {
        adminWhitelistRule.setMasterKillSwitch(false)
    }
} catch (Exception e) {
    println "Could not configure AdminWhitelistRule: ${e.message}"
}

instance.save()

println "Admin user created and security configured"
