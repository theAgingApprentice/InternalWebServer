# MitchellNET (Internal WebServer)

This repository describes the full setup, configuration, and workflow of the **MitchellNET Internal WebServer**, a local, containerized NGINX-based deployment hosted on a 2019 iMac Ubuntu Server, with development and CI/CD orchestration managed via a Mac Studio and GitHub Actions.

---

## 📑 Table of Contents
1. [Overview](#overview)
2. [System Architecture](#system-architecture)
   - [Development Environment (Mac Studio)](#development-environment-mac-studio)
   - [Version Control and GitHub Actions](#version-control-and-github-actions)
   - [Server Environment (2019 iMac Ubuntu)](#server-environment-2019-imac-ubuntu)
3. [Initial Setup](#initial-setup)
   - [1. Local Development Setup](#1-local-development-setup)
   - [2. GitHub Repository Setup](#2-github-repository-setup)
   - [3. Ubuntu Server Setup](#3-ubuntu-server-setup)
   - [4. NGINX Reverse Proxy and SSL Configuration](#4-nginx-reverse-proxy-and-ssl-configuration)
4. [Deployment Workflow](#deployment-workflow)
   - [Development → Test](#development--test)
   - [Test → Production Promotion](#test--production-promotion)
5. [Branching Strategy](#branching-strategy)
6. [Cloning and Replicating the Environment](#cloning-and-replicating-the-environment)
7. [Troubleshooting and Maintenance](#troubleshooting-and-maintenance)

---

## 🧭 Overview

The MitchellNET web system provides an internal HTTPS website for local use, served by **Nginx running in Docker containers** on a **2019 iMac (Ubuntu Server 24.04.2 LTS)**.  
Development occurs on a **Mac Studio**, with automated CI/CD deployments using **GitHub Actions**.

Environments:
- **Development** → Mac Studio (local Visual Studio Code)
- **Test** → iMac Ubuntu Server via GitHub Actions (self-hosted runner)
- **Production** → iMac Ubuntu Server (promoted from Test)

---

## 🖥️ System Architecture

### Development Environment (Mac Studio)
| Component | Details |
|------------|----------|
| **Hardware** | Apple Mac Studio |
| **OS** | macOS Sonoma |
| **IDE** | Visual Studio Code |
| **Git Client** | Built-in Git integration |
| **SSH Keys** | Stored in `~/.ssh/id_rsa` and registered in GitHub Secrets |
| **Primary Directory** | `/Users/andrewmitchell/Documents/visualStudioCode/html/projects/InternalWebServer` |

All source content and workflows are developed and pushed to the remote GitHub repository:
```
https://github.com/theAgingApprentice/InternalWebServer.git
```

---

### Version Control and GitHub Actions
| Component | Details |
|------------|----------|
| **Repo** | `theAgingApprentice/InternalWebServer` |
| **Remote URL** | `https://github.com/theAgingApprentice/InternalWebServer.git` |
| **Runner** | Self-hosted runner on iMac (`imac-server-runner`) |
| **Secrets Used** | `SSH_PRIVATE_KEY`, `DEPLOY_USER`, `DEPLOY_HOST`, `DEPLOY_PATH` |
| **Workflows** | `.github/workflows/deploy-test.yml`, `.github/workflows/deploy-prod.yml` |

These workflows automate:
- Deployment of `develop` branch → Test environment
- Deployment of `main` branch → Production environment

---

### Server Environment (2019 iMac Ubuntu)
| Component | Details |
|------------|----------|
| **Hardware** | iMac 2019 (Model: iMac19,1) |
| **CPU** | 3.1 GHz 6-Core Intel Core i5 |
| **Memory** | 32 GB DDR4 |
| **OS** | Ubuntu Server 24.04.2 LTS |
| **Docker** | v28.3.1 |
| **NGINX** | `nginx:latest` Docker image |
| **Location** | Electronics Lab — accessible only on MitchellNET LAN |
| **IP Address** | `192.168.2.10` |

#### Directory Structure
```
/home/andrew/web_server/html/
├── index.html
├── test/
│   └── index.html
└── prod/
    └── index.html
```

---

## ⚙️ Initial Setup

### 1. Local Development Setup
1. Clone the GitHub repository:
   ```bash
   git clone https://github.com/theAgingApprentice/InternalWebServer.git
   ```
2. Create an SSH key if not already present:
   ```bash
   ssh-keygen -t rsa -b 4096 -C "andrewmitchell@macstudio"
   ```
3. Add your public key to the Ubuntu server:
   ```bash
   ssh-copy-id andrew@192.168.2.10
   ```
4. Test SSH connection:
   ```bash
   ssh andrew@192.168.2.10
   ```

---

### 2. GitHub Repository Setup
1. Add a remote:
   ```bash
   git remote add origin https://github.com/theAgingApprentice/InternalWebServer.git
   ```
2. Add repository secrets:
   | Name | Description |
   |------|--------------|
   | `SSH_PRIVATE_KEY` | Your Mac Studio’s private SSH key |
   | `DEPLOY_USER` | `andrew` |
   | `DEPLOY_HOST` | `192.168.2.10` |
   | `DEPLOY_PATH` | `/home/andrew/web_server/html` |

3. Push branches:
   ```bash
   git push origin develop
   git push origin main
   ```

---

### 3. Ubuntu Server Setup
1. Install Docker and GitHub Runner:
   ```bash
   sudo apt update && sudo apt install -y docker.io git
   ```
2. Register the GitHub self-hosted runner:
   - Go to your repo → **Settings → Actions → Runners → New self-hosted runner**
   - Follow the registration commands (as `andrew` user)
3. Start the runner service:
   ```bash
   ./svc.sh install
   ./svc.sh start
   ```

---

### 4. NGINX Reverse Proxy and SSL Configuration

#### Proxy Overview
Three NGINX containers manage traffic:
| Container | Purpose | Path |
|------------|----------|------|
| `nginx-proxy` | Reverse proxy (SSL termination) | `/usr/share/nginx/html` |
| `nginx-test` | Serves test environment | `/home/andrew/web_server/html/test` |
| `nginx-prod` | Serves production environment | `/home/andrew/web_server/html/prod` |

#### SSL Certificate
Self-signed SSL/TLS cert:
```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048   -keyout /etc/ssl/private/selfsigned.key   -out /etc/ssl/certs/selfsigned.crt   -subj "/C=CA/ST=Ontario/L=London/O=TheAgingApprentice/CN=Andrew Mitchell/emailAddress=va3wam@gmail.com"
```

---

## 🚀 Deployment Workflow

### Development → Test
When code is pushed to the `develop` branch:
1. GitHub Action (`deploy-test.yml`) runs on `imac-server-runner`.
2. Workflow connects to Ubuntu via SSH using secrets.
3. Files sync to `/home/andrew/web_server/html/test/`.
4. `https://192.168.2.10/test/` serves the updated version.

### Test → Production Promotion
Once validated, changes are merged into `main`:
1. GitHub Action (`deploy-prod.yml`) runs.
2. Files deploy to `/home/andrew/web_server/html/prod/`.
3. `https://192.168.2.10/` serves the production content.

---

## 🌿 Branching Strategy

| Branch | Purpose | Deployment Target |
|---------|----------|-------------------|
| `develop` | Active development and testing | `/test/` environment |
| `main` | Stable production-ready code | `/prod/` environment |

**Workflow:**
1. Create feature branches from `develop`
2. Open PRs into `develop` for integration testing
3. Merge `develop` → `main` for release to production

---

## 🔁 Cloning and Replicating the Environment

To recreate this setup on a new network or device:
1. Clone the repository:
   ```bash
   git clone https://github.com/theAgingApprentice/InternalWebServer.git
   ```
2. Run the provided setup script (`setup_environment.sh`) to:
   - Generate SSH keys  
   - Register a new GitHub runner  
   - Deploy Docker + NGINX + certificates
3. Update `.github/workflows` secrets for the new environment.

---

## 🛠️ Troubleshooting and Maintenance
- **Workflow Fails with SSH Error** → Ensure Ubuntu server is reachable by runner (private LAN only)
- **Certificate Mismatch** → Regenerate `selfsigned.crt` and `selfsigned.key`
- **Nginx Proxy Issues** → Check container logs:
  ```bash
  sudo docker logs nginx-proxy
  ```
- **Re-register GitHub Runner** (if it goes offline):
  ```bash
  ./config.sh remove
  ./config.sh
  ```

---

© 2025 TheAgingApprentice — Internal use only.
