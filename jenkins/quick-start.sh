#!/bin/bash

# Quick Start Script for Max Weather API Jenkins Setup

set -e

echo "🚀 Max Weather API - Jenkins Quick Start"
echo "========================================"

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Check for environment file
if [ ! -f "env.example" ]; then
    echo "❌ Environment template not found. Please run this script from the jenkins directory."
    exit 1
fi

# Setup environment if needed
if [ ! -f ".env" ]; then
    echo "📝 Setting up environment configuration..."
    cp env.example .env
    echo "✅ Environment file created. Please edit .env with your actual values."
    echo "   You can continue with default values for now."
    read -p "Press Enter to continue..."
fi

# Build and start Jenkins
echo "🔨 Building Jenkins image..."
make build

echo "🚀 Starting Jenkins..."
make up

echo "⏳ Waiting for Jenkins to be ready..."
make wait

echo ""
echo "🎉 Jenkins is ready!"
echo "==================="
echo "🌐 Access Jenkins at: http://localhost:8080"
echo "👤 Username: admin"
echo "🔑 Password: admin123 (or your configured password)"
echo ""
echo "📋 Next steps:"
echo "1. Open Jenkins in your browser"
echo "2. Check that the 'max-weather-deployment' job is created"
echo "3. Configure your AWS credentials if needed"
echo "4. Run the pipeline job to test deployment"
echo ""
echo "🛠️  Useful commands:"
echo "   make logs     - View Jenkins logs"
echo "   make shell     - Shell into Jenkins container"
echo "   make backup    - Backup Jenkins configuration"
echo "   make down      - Stop Jenkins"
echo ""
echo "📚 For more information, see README.md"
