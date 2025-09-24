#!/bin/bash

echo "🚀 Deploying GlobalConnect.store..."

# Variables
SERVER_IP="193.168.173.62"
SERVER_USER="root"
PROJECT_PATH="/opt/globalconnect"

# Build frontend
echo "📦 Building frontend..."
cd frontend
npm run build
cd ..

# Create deployment package
echo "📦 Creating deployment package..."
tar -czf deploy.tar.gz \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='*.log' \
  --exclude='.env' \
  .

# Upload to server
echo "📤 Uploading to server..."
scp deploy.tar.gz $SERVER_USER@$SERVER_IP:/tmp/
ssh $SERVER_USER@$SERVER_IP "
  cd $PROJECT_PATH
  tar -xzf /tmp/deploy.tar.gz
  docker-compose down
  docker-compose up -d --build
  docker system prune -f
  rm /tmp/deploy.tar.gz
"

# Cleanup
rm deploy.tar.gz

echo "✅ Deployment complete!"
echo "🌍 Visit: https://globalconnect.store"
