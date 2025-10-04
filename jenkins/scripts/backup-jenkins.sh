#!/bin/bash

# Backup Jenkins configuration
BACKUP_DIR="/var/jenkins_home/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="jenkins_backup_${TIMESTAMP}.tar.gz"

echo "Creating Jenkins backup..."

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create backup
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
    --exclude="workspace" \
    --exclude="logs" \
    --exclude="backups" \
    /var/jenkins_home

echo "Backup created: $BACKUP_DIR/$BACKUP_FILE"

# Keep only last 10 backups
cd "$BACKUP_DIR"
ls -t jenkins_backup_*.tar.gz | tail -n +11 | xargs -r rm

echo "Backup completed"
