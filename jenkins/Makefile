# Jenkins Management Makefile for Max Weather API

.PHONY: help build up down logs shell backup restore clean restart validate

# Default target
help:
	@echo "Jenkins Management Commands:"
	@echo "  build       - Build custom Jenkins Docker image"
	@echo "  up          - Start Jenkins with docker-compose"
	@echo "  down        - Stop Jenkins"
	@echo "  logs        - Show Jenkins logs"
	@echo "  shell       - Shell into Jenkins container"
	@echo "  backup      - Backup Jenkins home directory"
	@echo "  restore     - Restore Jenkins backup"
	@echo "  clean       - Clean Jenkins volumes"
	@echo "  restart     - Restart Jenkins container"
	@echo "  validate    - Validate JCasC configuration"

# Build custom Jenkins image
build:
	@echo "Building custom Jenkins image..."
	docker build -t max-weather-jenkins:latest .

# Start Jenkins
up:
	@echo "Starting Jenkins..."
	docker-compose -f ../docker-compose.jenkins.yml up -d
	@echo "Jenkins is starting up. Access it at http://localhost:8080"
	@echo "Default credentials: admin / admin123"

# Stop Jenkins
down:
	@echo "Stopping Jenkins..."
	docker-compose -f ../docker-compose.jenkins.yml down

# Show Jenkins logs
logs:
	docker-compose -f ../docker-compose.jenkins.yml logs -f jenkins

# Shell into Jenkins container
shell:
	docker exec -it max-weather-jenkins /bin/bash

# Backup Jenkins
backup:
	@echo "Creating Jenkins backup..."
	docker exec max-weather-jenkins /usr/local/bin/backup-jenkins.sh

# Restore Jenkins (requires backup file)
restore:
	@echo "Restoring Jenkins backup..."
	@read -p "Enter backup file path: " backup_file; \
	docker cp $$backup_file max-weather-jenkins:/tmp/backup.tar.gz; \
	docker exec max-weather-jenkins tar -xzf /tmp/backup.tar.gz -C /; \
	docker exec max-weather-jenkins rm /tmp/backup.tar.gz

# Clean Jenkins volumes
clean:
	@echo "Cleaning Jenkins volumes..."
	docker-compose -f ../docker-compose.jenkins.yml down -v
	docker volume prune -f

# Restart Jenkins
restart: down up

# Validate JCasC configuration
validate:
	@echo "Validating JCasC configuration..."
	docker run --rm -v $(PWD)/casc.yaml:/casc.yaml jenkins/jenkins:lts \
		java -jar /usr/share/jenkins/jenkins.war --dry-run --casc-config /casc.yaml

# Wait for Jenkins to be ready
wait:
	@echo "Waiting for Jenkins to be ready..."
	@timeout 300 bash -c 'until curl -f http://localhost:8080/login >/dev/null 2>&1; do sleep 5; done' || echo "Jenkins startup timeout"

# Setup Jenkins (build, start, wait)
setup: build up wait
	@echo "Jenkins setup completed!"
	@echo "Access Jenkins at: http://localhost:8080"
	@echo "Username: admin"
	@echo "Password: admin123"

# Full reset (clean and setup)
reset: clean setup
