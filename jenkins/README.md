# Jenkins CI/CD Setup for Max Weather API

This directory contains a complete Jenkins setup with Configuration as Code (JCasC) and job bootstrapping for the Max Weather API deployment pipeline.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- AWS credentials (optional)
- Kubernetes cluster access (optional)

### 1. Start Jenkins
```bash
# Copy environment file
cp jenkins/env.example .env.jenkins

# Edit environment variables
nano .env.jenkins

# Start Jenkins
docker-compose -f docker-compose.jenkins-simple.yml up -d
```

### 2. Access Jenkins
- **URL**: http://localhost:8080
- **Login**: admin / admin123

### 3. Create Pipeline Job
The Jenkins instance is pre-configured with:
- ✅ Admin user (admin/admin123)
- ✅ AWS credentials (if provided)
- ✅ Environment variables
- ✅ Security configuration
- ✅ Seed job for bootstrapping

## 📁 Directory Structure

```
jenkins/
├── Dockerfile                    # Custom Jenkins image
├── Dockerfile.simple            # Simplified Jenkins image
├── casc.yaml                    # Configuration as Code
├── plugins.txt                  # Required plugins
├── env.example                  # Environment variables template
├── docker-compose.jenkins.yml   # Full Jenkins setup
├── docker-compose.jenkins-simple.yml # Simplified setup
├── init.groovy.d/               # Initialization scripts
│   ├── 01-disable-setup-wizard.groovy
│   ├── 02-create-admin-user.groovy
│   ├── 03-configure-aws.groovy
│   ├── 04-configure-kubernetes.groovy
│   └── 05-run-seed-job.groovy
├── jobs/                        # Job DSL scripts
│   ├── cleanup-pipeline.groovy
│   ├── infrastructure-pipeline.groovy
│   ├── max-weather-pipeline.groovy
│   └── seed-job.groovy
├── scripts/                     # Helper scripts
│   ├── wait-for-jenkins.sh
│   ├── configure-credentials.sh
│   ├── backup-jenkins.sh
│   └── restore-jenkins.sh
├── create-pipeline-job.sh       # Pipeline creation script
├── setup-jobs.sh               # Job setup script
└── Makefile                    # Management commands
```

## 🔧 Configuration

### Environment Variables
Edit `.env.jenkins` with your values:

```bash
# Jenkins Configuration
JENKINS_ADMIN_PASSWORD=admin123

# AWS Configuration
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_REGION=us-west-2
EKS_CLUSTER_NAME=max-weather-cluster
ECR_REGISTRY=123456789012.dkr.ecr.us-west-2.amazonaws.com

# GitHub Configuration
GITHUB_TOKEN=your_github_token

# Docker Registry
DOCKER_REGISTRY_CREDENTIALS=your_docker_credentials
```

### Jenkins Configuration as Code (JCasC)
The `casc.yaml` file contains:
- Security configuration
- Global tools (Docker, kubectl, AWS CLI, Terraform)
- Credentials management
- System properties
- Environment variables

## 🎯 Pipeline Features

### Max Weather API Deployment Pipeline
- **Parameters**: ENVIRONMENT, IMAGE_TAG, DEPLOY_BRANCH
- **Stages**: Checkout, Build, Deploy
- **Environment**: AWS, EKS, ECR integration
- **Notifications**: Success/failure handling

### Job Bootstrapping
- Automatic job creation on startup
- Seed job for pipeline management
- Configuration as Code integration
- Plugin management

## 🛠️ Management Commands

### Using Makefile
```bash
# Build Jenkins image
make jenkins-build

# Start Jenkins
make jenkins-up

# Stop Jenkins
make jenkins-down

# View logs
make jenkins-logs

# Access Jenkins shell
make jenkins-shell

# Backup Jenkins data
make jenkins-backup

# Restore Jenkins data
make jenkins-restore

# Clean up
make jenkins-clean

# Restart Jenkins
make jenkins-restart

# Validate configuration
make jenkins-validate
```

### Manual Commands
```bash
# Start Jenkins
docker-compose -f docker-compose.jenkins-simple.yml up -d

# View logs
docker-compose -f docker-compose.jenkins-simple.yml logs -f

# Stop Jenkins
docker-compose -f docker-compose.jenkins-simple.yml down

# Access Jenkins container
docker exec -it max-weather-jenkins bash
```

## 🔍 Troubleshooting

### Common Issues

1. **Jenkins won't start**
   - Check logs: `docker logs max-weather-jenkins`
   - Verify port 8080 is available
   - Check Docker daemon is running

2. **Login issues**
   - Default credentials: admin/admin123
   - Check if admin user was created in logs

3. **Plugin installation fails**
   - Check internet connectivity
   - Verify plugin names in plugins.txt
   - Restart Jenkins after plugin changes

4. **Job creation fails**
   - Check CSRF protection settings
   - Verify Job DSL plugin is installed
   - Check Groovy script syntax

### Logs and Debugging
```bash
# View Jenkins logs
docker logs max-weather-jenkins -f

# Check initialization scripts
docker exec max-weather-jenkins cat /var/jenkins_home/init.groovy.d/*.groovy

# Verify plugins
docker exec max-weather-jenkins ls /var/jenkins_home/plugins/

# Check configuration
docker exec max-weather-jenkins cat /var/jenkins_home/casc.yaml
```

## 📋 Next Steps

1. **Access Jenkins**: http://localhost:8080
2. **Login**: admin / admin123
3. **Create Pipeline Job**: Use the provided XML configuration
4. **Configure Credentials**: Add AWS, GitHub, Docker Hub credentials
5. **Test Pipeline**: Run the max-weather-deployment job
6. **Customize**: Modify pipeline stages as needed

## 🔒 Security Notes

- Change default admin password
- Use environment variables for sensitive data
- Enable HTTPS in production
- Configure proper firewall rules
- Regular security updates

## 📚 Additional Resources

- [Jenkins Configuration as Code](https://github.com/jenkinsci/configuration-as-code-plugin)
- [Job DSL Plugin](https://github.com/jenkinsci/job-dsl-plugin)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Docker-in-Docker Setup](https://docs.docker.com/engine/security/rootless/)

---

**Status**: ✅ Jenkins is running with job bootstrapping
**Access**: http://localhost:8080 (admin/admin123)
**Pipeline**: max-weather-deployment (ready to create)
