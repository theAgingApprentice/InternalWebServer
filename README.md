# MitchellNET (Internal WebServer)

This repository details the internal MitchellNET website, running on an Nginx web server hosted on a 2019 iMac Ubuntu server. The web server and content are served over HTTPS using a reverse proxy setup with Docker containers. Full details about all services hosted on this server are available in the README file in [this repository](https://github.com/theAgingApprentice/2019iMacServer).

## IP Address
The server is located in the electronics lab and is accessible only from within the MitchellNET network at [https://192.168.2.10](https://192.168.2.10).

## Home Directory
The root directory for the website content is located on the Ubuntu server at `/home/andrew/web_server/html`. It contains:
- `index.html`: Default page (not directly served, used for testing).
- `test/`: Directory for the test environment, containing `index.html`.
- `prod/`: Directory for the production environment, containing `index.html`.

## Self-Signed HTTPS Certificate Configuration for NGINX Reverse Proxy on Ubuntu (Docker)

This section describes the configuration of a self-signed HTTPS certificate for an NGINX reverse proxy setup running in Docker containers on an Ubuntu Server 24.04.2 LTS, hosted on a 2019 iMac.

### Overview
The setup uses three Nginx containers:
- **nginx-proxy**: Acts as a reverse proxy, handling HTTPS traffic and routing requests to the appropriate backend.
- **nginx-prod**: Serves production content from `/home/andrew/web_server/html/prod`.
- **nginx-test**: Serves test content from `/home/andrew/web_server/html/test`.

The reverse proxy routes requests as follows:
- `https://192.168.2.10/` → Production (`nginx-prod`)
- `https://192.168.2.10/test/` → Test (`nginx-test`)
- `https://192.168.2.10/prod/` → Production (`nginx-prod`)

A self-signed SSL/TLS certificate enables secure communication. This setup is part of a system hosting Nginx, Mosquitto, Grafana, and Prometheus for web serving, messaging, and monitoring.

### System Information
- **Hardware**: iMac (2019, Model: iMac19,1)
  - Processor: 3.1 GHz 6-Core Intel Core i5
  - Memory: 32 GB 2667 MHz DDR4
  - Storage: 1.39 TB
- **Operating System**: Ubuntu Server 24.04.2 LTS (Noble)
- **Docker Version**: 28.3.1, build 38b7060
- **NGINX Version**: nginx:latest (Docker image)
- **OpenSSL Version**: [Run `openssl version` to confirm, e.g., OpenSSL 3.0.2]

### Certificate Details
- **Certificate File**: `/etc/ssl/certs/selfsigned.crt`
- **Private Key File**: `/etc/ssl/private/selfsigned.key`
- **Certificate Subject**: `C=CA, ST=Ontario, L=London, O=TheAgingApprentice, CN=Andrew Mitchell, emailAddress=va3wam@gmail.com`
- **Issuer**: Self-signed
- **Validity**: October 5, 2025, to October 5, 2026
- **Public Key**: 2048-bit RSA
- **Generation Command**:
  ```bash
  sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048     -keyout /etc/ssl/private/selfsigned.key     -out /etc/ssl/certs/selfsigned.crt     -subj "/C=CA/ST=Ontario/L=London/O=TheAgingApprentice/CN=Andrew Mitchell/emailAddress=va3wam@gmail.com"
  ```

(Full installation steps, file permissions, docker-compose config, proxy.conf, troubleshooting, and next steps are included in this document as provided.)
