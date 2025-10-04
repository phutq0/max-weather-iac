// Cleanup Pipeline
// This DSL script creates the cleanup and maintenance pipeline

job('cleanup-maintenance') {
    description('Cleanup and Maintenance Pipeline - Cleans up old builds, artifacts, and performs maintenance tasks')
    
    label('master')
    
    triggers {
        cron('0 2 * * *') // Run daily at 2 AM
    }
    
    steps {
        shell('''
            #!/bin/bash
            echo "Starting cleanup and maintenance tasks..."
            
            # Clean up old builds (keep last 10)
            echo "Cleaning up old builds..."
            find /var/jenkins_home/jobs/*/builds -maxdepth 1 -type d -name "[0-9]*" | sort -n | head -n -10 | xargs rm -rf 2>/dev/null || true
            
            # Clean up old artifacts
            echo "Cleaning up old artifacts..."
            find /var/jenkins_home/jobs/*/builds -name "*.log" -mtime +7 -delete 2>/dev/null || true
            find /var/jenkins_home/jobs/*/builds -name "*.zip" -mtime +7 -delete 2>/dev/null || true
            
            # Clean up Docker images
            echo "Cleaning up Docker images..."
            docker image prune -f 2>/dev/null || true
            
            # Clean up Docker volumes
            echo "Cleaning up Docker volumes..."
            docker volume prune -f 2>/dev/null || true
            
            # Clean up Jenkins workspace
            echo "Cleaning up Jenkins workspace..."
            find /var/jenkins_home/workspace -type d -name "workspace" -mtime +7 -exec rm -rf {} + 2>/dev/null || true
            
            # Clean up logs
            echo "Cleaning up old logs..."
            find /var/jenkins_home/logs -name "*.log.*" -mtime +30 -delete 2>/dev/null || true
            
            echo "Cleanup completed successfully"
        ''')
    }
    
    publishers {
        // Archive build artifacts
        archiveArtifacts('**/*.log')
        
        // Send email notification
        mailer('admin@max-weather.com', false, true)
    }
}
