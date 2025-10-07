#!/bin/bash
# ============================================================
# GitHub CI/CD Setup Script for InternalWebServer Project
# Target directory: /Users/andrewmitchell/Documents/visualStudioCode/html/projects/InternalWebServer
# ============================================================

set -e

echo "🚀 Setting up GitHub CI/CD workflow for InternalWebServer..."

# --- Create basic structure ---
mkdir -p html/test html/prod .github/workflows

# --- Create README if missing ---
if [ ! -f README.md ]; then
cat <<'EOF' > README.md
# Internal Web Server (CI/CD Enabled)

This repository hosts the website and deployment pipeline for the internal NGINX-based web server running on Ubuntu.  
It supports automated deployment to test and production environments using GitHub Actions.

## Branch Workflow
- **develop** → auto-deploys to test container
- **main** → manual promotion to production

See `.github/workflows` for CI/CD configuration.
EOF
fi

# --- Create docker-compose.yml (if missing) ---
if [ ! -f docker-compose.yml ]; then
cat <<'EOF' > docker-compose.yml
version: '3.8'

services:
  nginx-proxy:
    image: nginx:latest
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./proxy.conf:/etc/nginx/conf.d/default.conf:ro
      - ./html:/usr/share/nginx/html:ro
      - ./ssl:/etc/nginx/ssl:ro
    restart: unless-stopped

  nginx-test:
    image: nginx:latest
    container_name: nginx-test
    volumes:
      - ./html/test:/usr/share/nginx/html:ro
    restart: unless-stopped

  nginx-prod:
    image: nginx:latest
    container_name: nginx-prod
    volumes:
      - ./html/prod:/usr/share/nginx/html:ro
    restart: unless-stopped
EOF
fi

# --- Create proxy.conf ---
if [ ! -f proxy.conf ]; then
cat <<'EOF' > proxy.conf
server {
    listen 80;
    server_name 192.168.2.10;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name 192.168.2.10;

    ssl_certificate /etc/nginx/ssl/selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/selfsigned.key;

    location = / {
        proxy_pass http://nginx-prod;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location ^~ /prod {
        rewrite ^/prod/?(.*)\$ /\$1 break;
        proxy_pass http://nginx-prod;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location ^~ /test {
        rewrite ^/test/?(.*)\$ /\$1 break;
        proxy_pass http://nginx-test;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
fi

# --- Create GitHub Action: Deploy to Test ---
cat <<'EOF' > .github/workflows/deploy-test.yml
name: Deploy to Test

on:
  push:
    branches:
      - develop

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa

      - name: Copy files to Ubuntu server (test)
        run: |
          rsync -avz --delete \
            -e "ssh -o StrictHostKeyChecking=no" \
            html/test/ \
            ${{ secrets.DEPLOY_USER }}@${{ secrets.DEPLOY_HOST }}:${{ secrets.DEPLOY_PATH }}/test/

      - name: Restart nginx-test container
        run: |
          ssh -o StrictHostKeyChecking=no ${{ secrets.DEPLOY_USER }}@${{ secrets.DEPLOY_HOST }} \
          "docker restart nginx-test"
EOF

# --- Create GitHub Action: Promote to Prod ---
cat <<'EOF' > .github/workflows/promote-prod.yml
name: Promote to Production

on:
  workflow_dispatch:

jobs:
  promote:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa

      - name: Copy test content to production
        run: |
          ssh -o StrictHostKeyChecking=no ${{ secrets.DEPLOY_USER }}@${{ secrets.DEPLOY_HOST }} \
          "cp -r ${{ secrets.DEPLOY_PATH }}/test/* ${{ secrets.DEPLOY_PATH }}/prod/"

      - name: Restart nginx-prod container
        run: |
          ssh -o StrictHostKeyChecking=no ${{ secrets.DEPLOY_USER }}@${{ secrets.DEPLOY_HOST }} \
          "docker restart nginx-prod"
EOF

# --- Ensure git repo is initialized ---
if [ ! -d .git ]; then
  echo "🔧 Initializing git repository..."
  git init
  git branch -M develop
  git remote add origin https://github.com/theAgingApprentice/InternalWebServer.git
fi

# --- Commit and push changes ---
git add .
git commit -m "Set up CI/CD workflows and basic structure" || true
git push -u origin develop

echo "✅ CI/CD setup complete!"
echo "Now configure GitHub Secrets in your repository settings:"
echo "   DEPLOY_USER, DEPLOY_HOST, DEPLOY_PATH, SSH_PRIVATE_KEY"

