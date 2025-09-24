#!/bin/bash

echo "🔧 Setting up server for GlobalConnect.store..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Nginx and Certbot
sudo apt install nginx certbot python3-certbot-nginx -y

# Create project directory
sudo mkdir -p /opt/globalconnect
sudo chown $USER:$USER /opt/globalconnect

# Configure Nginx
sudo tee /etc/nginx/sites-available/globalconnect.store << 'NGINX_EOF'
server {
    listen 80;
    server_name globalconnect.store www.globalconnect.store;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api {
        proxy_pass http://localhost:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
NGINX_EOF

sudo ln -s /etc/nginx/sites-available/globalconnect.store /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# Get SSL certificate
sudo certbot --nginx -d globalconnect.store -d www.globalconnect.store

echo "✅ Server setup complete!"
echo "🔑 Remember to update DNS records to point to this server"
