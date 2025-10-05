# MitchellNET (Internal WebServer)
This repository details the new internal MitchellNET website that runs on an Nginx web server hosted on a 2019 iMac Ubuntu server. The server web server and content are sent over HTTPS from a Docker container. Full details about all the services hosted on this server are detailed in the README file in [this repository](https://github.com/theAgingApprentice/2019iMacServer).

# IP Address
This server is located in the electronics lab and is accessed only from within the MItchellNET network at [https://192.168.2.10](https://192.168.2.10).  

# Home Directory
The root directory for this web site is located on the Ubuntu server at /usr/share/nginx/html.

# Self-Signed HTTPS Certificate Configuration for NGINX on Ubuntu (Docker)

This section describes the configuration of a self-signed HTTPS certificate for an NGINX web server running in a Docker container on an Ubuntu Server 24.04.2 LTS, hosted on a 2019 iMac.

## Overview
The NGINX web server is deployed in a Docker container to serve web content over HTTPS for the internal IP `192.168.2.10` on the `MitchellNET` network. A self-signed SSL/TLS certificate enables secure communication. This setup is part of a system hosting Nginx, Mosquitto, Grafana, and Prometheus for web serving, messaging, and monitoring.

## System Information
- **Hardware**: iMac (2019, Model: iMac19,1)
  - Processor: 3.1 GHz 6-Core Intel Core i5
  - Memory: 32 GB 2667 MHz DDR4
  - Storage: 1.39 TB
- **Operating System**: Ubuntu Server 24.04.2 LTS (Noble)
- **Docker Version**: 28.3.1, build 38b7060
- **NGINX Version**: nginx:latest (Docker image)
- **OpenSSL Version**: [Run `openssl version` to confirm, e.g., OpenSSL 3.0.2]

## Certificate Details
- **Certificate File**: `/home/andrew/web_server/ssl/server.crt` (host path, maps to `/etc/nginx/ssl/server.crt` in container)
- **Private Key File**: `/home/andrew/web_server/ssl/server.key` (host path, maps to `/etc/nginx/ssl/server.key` in container)
- **Certificate Subject**: `C=CA, ST=Ontario, L=London, O=TheAgingApprentice, CN=Andrew Mitchell, emailAddress=va3wam@gmail.com`
- **Issuer**: Self-signed (same as subject)
- **Validity**: October 5, 2025, to October 5, 2026 (1 year)
- **Serial Number**: `72:c4:91:b8:45:8a:76:03:70:e6:eb:6f:94:bc:5c:6a:6f:31:09:dc`
- **Signature Algorithm**: SHA256 with RSA Encryption
- **Public Key**: 2048-bit RSA
- **Generation Command**:

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /home/andrew/web_server/ssl/server.key \
  -out /home/andrew/web_server/ssl/server.crt \
  -subj "/C=CA/ST=Ontario/L=London/O=TheAgingApprentice/CN=Andrew Mitchell/emailAddress=va3wam@gmail.com"
```

## NGINX Configuration
NGINX runs in a Docker container named `my-secure-web-server`.

### Container Details
- **Image**: nginx:latest
- **Ports**: 443 (HTTPS), 80 (HTTP-to-HTTPS redirect)
- **Volumes**:
  - `/home/andrew/web_server/html:/usr/share/nginx/html:ro`
  - `/home/andrew/web_server/nginx/conf.d:/etc/nginx/conf.d:ro`
  - `/home/andrew/web_server/ssl:/etc/nginx/ssl:ro`
- **Network**: web_server_default (IP: 172.19.0.2)
- **Restart Policy**: unless-stopped

### NGINX Server Blocks
```nginx
# Redirect all HTTP traffic to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name 192.168.2.10;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;

    root /usr/share/nginx/html;
    index index.html index.htm;

    server_name 192.168.2.10;

    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA256";
    ssl_prefer_server_ciphers on;

    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' data: 'unsafe-inline' 'unsafe-eval';" always;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Main NGINX Configuration (/etc/nginx/nginx.conf)
```nginx
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;
    sendfile on;
    keepalive_timeout 65;
    include /etc/nginx/conf.d/*.conf;
}
```

## Docker Setup
```bash
docker run -d --name my-secure-web-server \
  -v /home/andrew/web_server/html:/usr/share/nginx/html:ro \
  -v /home/andrew/web_server/nginx/conf.d:/etc/nginx/conf.d:ro \
  -v /home/andrew/web_server/ssl:/etc/nginx/ssl:ro \
  -p 443:443 \
  --network web_server_default \
  --restart unless-stopped \
  nginx:latest
```

## File Permissions
```bash
sudo chmod 644 /home/andrew/web_server/ssl/server.crt
sudo chmod 600 /home/andrew/web_server/ssl/server.key
sudo chown root:root /home/andrew/web_server/ssl/server.crt /home/andrew/web_server/ssl/server.key
```

## Installation Steps
1. **Generate the Self-Signed Certificate** (as above)
2. **Create NGINX Configuration** (default.conf with server blocks)
3. **Run Docker Container** (docker run command above)
4. **Test NGINX Configuration**
```bash
docker exec my-secure-web-server nginx -t
```
5. **Reload NGINX if needed**
```bash
docker exec my-secure-web-server nginx -s reload
```
6. **Verify HTTPS**: Access `https://192.168.2.10`

## Verification Commands
```bash
openssl x509 -in /home/andrew/web_server/ssl/server.crt -text -noout
docker exec my-secure-web-server nginx -t
sudo ss -tuln | grep 443
docker ps -a | grep my-secure-web-server
```

## Notes
- **CN Mismatch**: Certificate CN is Andrew Mitchell, may trigger browser warnings.
- **Alternative Files**: `fullchain.pem` and `privkey.key` may indicate Let’s Encrypt.
- **Certificate Renewal**: Expires October 5, 2026.
- **Backup**: Secure `/home/andrew/web_server/ssl/server.crt` and `/home/andrew/web_server/ssl/server.key`.
- **Access**: `https://192.168.2.10`

## Troubleshooting
- **Container fails to start**: `docker logs my-secure-web-server`
- **Certificate errors**: Verify paths and CN
- **Browser warnings**: Expected due to self-signed certificate
- **Port conflicts**: Ensure port 443 is free

## Certificate Next Steps
1. **Save README** to `/home/andrew/web_server/README.md`
2. **Fix CN mismatch** (optional)
3. **Investigate `fullchain.pem` and `privkey.key`** (optional)
4. **Provide OpenSSL Version** (optional)
5. **Verify Setup**

## After cerrtificate things to do
1. Create test and production dirctory structures 
2. Make a test and prod docker image
3. Create repo structure
4. Create Automated checkin and promote to test 


