FROM jenkins/jenkins:lts

# Switch to root user to install packages
USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    unzip \
    wget \
    git \
    make \
    build-essential \
    python3 \
    python3-pip \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz | tar -xzC /usr/local/bin --strip-components=1 docker/docker \
    && chmod +x /usr/local/bin/docker

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install --bin-dir /usr/local/bin \
    && rm -rf aws awscliv2.zip

# Install Helm
RUN curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz \
    && mv linux-amd64/helm /usr/local/bin/ \
    && rm -rf linux-amd64

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip \
    && unzip terraform_1.7.0_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && chmod +x /usr/local/bin/terraform \
    && rm terraform_1.7.0_linux_amd64.zip

RUN ls -la /usr/share/jenkins/ref/
# Install Jenkins plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Copy JCasC configuration
COPY casc.yaml /usr/share/jenkins/ref/casc.yaml

# Copy initialization scripts
COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

# Copy job DSL scripts
COPY jobs/ /usr/share/jenkins/ref/jobs/

# Copy helper scripts
COPY scripts/ /usr/local/bin/

# Set proper permissions
RUN chmod +x /usr/local/bin/*.sh \
    && chown -R jenkins:jenkins /usr/share/jenkins/ref

# Verify installations
# RUN docker --version \
#     && kubectl version --client \
#     && aws --version \
#     && helm version \
#     && terraform --version

# Switch back to jenkins user
USER jenkins

# Set environment variables
ENV CASC_JENKINS_CONFIG=/usr/share/jenkins/ref/casc.yaml
ENV JENKINS_OPTS="--httpPort=8080"
ENV JAVA_OPTS="-Xmx2048m -Xms1024m -Djenkins.install.runSetupWizard=false"

# Expose port
EXPOSE 8080 50000
