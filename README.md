# InternalWebServer - Production Deployment

> **Author:** Andrew Mitchell (TheAgingApprentice)  
> **System:** Ubuntu Server 24.04.2 LTS (iMac19,1, 2019 iMac)  
> **Deployment:** Simplified single-branch workflow with GitHub Actions  
> **Last Updated:** December 21, 2025

---

## 📑 Table of Contents
1. [Overview](#1-overview)
2. [Local Development Setup](#2-local-development-setup)
   - [Prerequisites](#prerequisites)
   - [Running Docker Locally](#running-docker-locally)
   - [Testing Changes Locally](#testing-changes-locally)
3. [Deployment Workflow](#3-deployment-workflow)
   - [Making Changes](#making-changes)
   - [Pull Request Deployment](#pull-request-deployment)
4. [Production Environment](#4-production-environment)
5. [Troubleshooting](#5-troubleshooting)
6. [Rollback Procedure](#6-rollback-procedure)
7. [System Architecture](#7-system-architecture)
8. [Custom Applications](#8-custom-applications)
9. [SSL Certificate Setup for iOS Devices](#9-ssl-certificate-setup-for-ios-devices)
   - [Certificate Details](#certificate-details)
   - [Installing Certificate on iOS](#installing-certificate-on-ios)
   - [Accessing the Website](#accessing-the-website)
   - [Regenerating the Certificate](#regenerating-the-certificate)
   - [Troubleshooting iOS Access](#troubleshooting-ios-access)
10. [SSL Certificate Setup for macOS Devices](#10-ssl-certificate-setup-for-macos-devices)
   - [Quick Installation](#quick-installation)
   - [GUI Installation](#gui-installation)
   - [Verification](#verification)
   - [Troubleshooting macOS Certificate Issues](#troubleshooting-macos-certificate-issues)
11. [Connected Services](#11-connected-services)
12. [Network](#12-network)

---

## 1. Overview

**InternalWebServer** is a simplified NGINX-based web hosting solution for MitchellNET. It is hosted on a [2019 iMac](https://github.com/theAgingApprentice/2019iMacServer). This repository uses a streamlined deployment process:

✅ **Single Branch:** Work directly on `main` branch or feature branches  
✅ **Automated Deployment:** Merging PR to `main` auto-deploys to production  
✅ **Local Testing:** Test changes locally before pushing to GitHub  
✅ **Simple Infrastructure:** Only production environment maintained

### URL Reference

| URL | Points To | Purpose |
|-----|-----------|----------|
| **https://mitchellnet.local** | Ubuntu server (192.168.2.10) | Production site |
| **https://mitchellnet.dev.local** | Local Mac (127.0.0.1) | Local development/preview |

---

## 2. Local Development Setup

### Prerequisites

Before you can develop locally, you need:

1. **Docker Desktop** (recommended) OR **Docker CLI**
2. **Git** installed and configured
3. **This repository** cloned to your Mac

### Running Docker Locally

#### Option 1: Docker Desktop (Recommended)

1. **Install Docker Desktop:**
   - Download from [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
   - Install and launch Docker Desktop
   - Verify it's running (Docker icon in menu bar)

2. **Verify Docker is running:**
   ```bash
   docker ps
   # Should show running containers or empty list (not an error)
   ```

#### Option 2: Docker via Command Line

If you prefer command-line only:

1. **Start Docker service:**
   ```bash
   # Docker Desktop must be installed (even for CLI use on Mac)
   open -a Docker
   ```

2. **Verify Docker daemon is running:**
   ```bash
   docker info
   # Should show system-wide information
   ```

### Testing Changes Locally

#### Step 1: Start Local Development Environment

```bash
# Navigate to project directory
cd /Users/andrewmitchell/Documents/visualStudioCode/html/projects/InternalWebServer

# Start local containers (uses docker-compose.dev.yml)
make up

# Verify containers are running
docker ps
```

You should see containers running:
- `nginx-proxy-dev` - Reverse proxy on ports 80/443
- `nginx-prod-dev` - Production content server

#### Step 2: Make Your Changes

Edit files in `html/prod/`:
```bash
# Example: Edit the home page
code html/prod/index.html

# Or edit styles
code html/prod/css/style.css
```

#### Step 3: View Changes Locally

**Option A: Using localhost (Easiest)**

1. Add to `/etc/hosts` (one-time setup):
   ```bash
   sudo nano /etc/hosts
   ```

2. Add this line:
   ```
   127.0.0.1 mitchellnet.dev.local
   ```

3. View in browser:
   - Local dev: https://mitchellnet.dev.local

**Option B: Using VS Code Live Preview**

1. Install "Live Preview" extension in VS Code
2. Right-click `html/prod/index.html`
3. Select "Show Preview"

**Option C: Direct File Preview**

1. Open file in browser:
   ```bash
   open html/prod/index.html
   ```
   
   ⚠️ Note: This won't load assets with absolute paths correctly

#### Step 4: Reload NGINX (if needed)

If you change NGINX configuration:
```bash
make reload
```

#### Step 5: View Logs

```bash
# Watch all container logs
make logs

# Or specific container
docker logs -f nginx-proxy-dev
```

#### Step 6: Stop Containers

When done testing:
```bash
make down
```

---

## 3. Deployment Workflow

### URL Summary

| Environment | URL | Access From |
|-------------|-----|-------------|
| **Production** | https://mitchellnet.local | Any device on MitchellNET |
| **Local Dev** | https://mitchellnet.dev.local | Your Mac only |

### Feature Branch Workflow

This repository uses a **single-branch workflow** with temporary feature branches for new work.

**Key Principles:**
- ✅ Only `main` branch is permanent
- ✅ Create feature branches for each piece of work
- ✅ Delete feature branches after merging
- ✅ Never commit directly to `main` (use PRs instead)

---

#### Complete Feature Workflow

**1. Start New Feature**

```bash
# Make sure you're on main and up to date
git checkout main
git pull origin main

# Create a new feature branch (use descriptive names)
git checkout -b feature/add-contact-page
# or
git checkout -b feature/update-navigation
# or
git checkout -b fix/broken-image-link
```

**Naming conventions:**
- `feature/` - New features or enhancements
- `fix/` - Bug fixes
- `update/` - Content updates or improvements

---

**2. Make Your Changes**

```bash
# Edit files
code html/prod/index.html
code html/prod/header.html
code html/prod/css/style.css

# Or use your preferred editor
```

---

**3. Test Locally**

```bash
# Start development containers
make up

# View changes at https://mitchellnet.dev.local
# Test navigation, links, styling, etc.

# Make additional changes if needed
# Containers auto-reload for HTML/CSS/JS changes

# When satisfied, stop containers
make down
```

---

**4. Commit Your Changes**

```bash
# Check what files changed
git status

# Stage your changes
git add html/prod/
# or add specific files
git add html/prod/index.html html/prod/css/style.css

# Commit with a clear message
git commit -m "Add contact page with email form"

# Push to GitHub
git push origin feature/add-contact-page
```

**Good commit messages:**
- ✅ "Add contact page with email form"
- ✅ "Fix navigation table alignment"
- ✅ "Update home page hero image"
- ❌ "updates" (too vague)
- ❌ "WIP" (work in progress - commit when done)

---

**5. Create Pull Request**

```bash
# GitHub will show a link in the terminal output:
# https://github.com/theAgingApprentice/InternalWebServer/pull/new/feature/add-contact-page

# Or go to GitHub and click "Compare & pull request"
```

On GitHub:
1. Review your changes in the "Files changed" tab
2. Write a description of what you changed
3. Click "Create pull request"

---

**6. Merge Pull Request**

Since you're the only developer:
1. Review the changes one final time
2. Click "Merge pull request"
3. Click "Confirm merge"
4. **Check "Delete branch" checkbox** (clean up automatically)
5. Click "Delete branch" to remove the feature branch

This triggers automatic deployment! 🚀

---

**7. Clean Up Locally**

After merging and deleting the remote branch:

```bash
# Switch back to main
git checkout main

# Pull the merged changes
git pull origin main

# Delete your local feature branch
git branch -d feature/add-contact-page

# Verify only main remains
git branch
# Should show: * main
```

---

#### Quick Reference

**Complete workflow in one block:**

```bash
# Start
git checkout main && git pull origin main
git checkout -b feature/my-feature

# Work
# ... edit files ...
make up  # test locally
make down

# Commit
git add html/prod/
git commit -m "Clear description of changes"
git push origin feature/my-feature

# Create PR on GitHub, merge it, delete remote branch

# Clean up
git checkout main
git pull origin main
git branch -d feature/my-feature
```

---

#### Troubleshooting Feature Branches

**Forgot to create a feature branch and worked on main?**

```bash
# Don't panic! Create the branch now
git checkout -b feature/my-forgotten-feature

# Your changes come with you
git push origin feature/my-forgotten-feature

# Now create PR as normal
```

**Want to abandon a feature branch?**

```bash
# Switch to main
git checkout main

# Delete local branch (use -D to force)
git branch -D feature/unwanted-feature

# Delete from GitHub (if you pushed it)
git push origin --delete feature/unwanted-feature
```

**Need to update feature branch with latest main?**

```bash
# While on your feature branch
git checkout feature/my-feature

# Pull latest main changes
git pull origin main

# Resolve any conflicts if needed
# Then continue working
```

---

### Deployment Methods

#### Method 1: Automated via Pull Request (Recommended)

This is the **preferred method** as it provides automatic backups, verification, and deployment logs.

**Steps:**
1. Create and push your feature branch (see above)
2. Go to GitHub and create a Pull Request to `main`
3. Review the changes in the PR
4. Click "Merge Pull Request"
5. GitHub Actions automatically:
   - Backs up current production to `/home/andrew/web_server/backups/`
   - Deploys your changes to `/home/andrew/web_server/html/prod/`
   - Restarts nginx containers
   - Verifies deployment succeeded
   - Creates `version.json` with deployment metadata

**Monitor deployment:**
- Go to GitHub → Actions tab
- Watch the "Deploy to Production" workflow
- Check for ✅ success or ❌ failure

**Advantages:**
- ✅ Automatic backups
- ✅ Deployment verification
- ✅ Audit trail in GitHub Actions
- ✅ Rollback capability
- ✅ Deployment metadata tracking

---

#### Method 2: Manual Deployment

Use this when you push directly to `main` (which bypasses the PR workflow) or need to deploy urgently.

**When to use:**
- You pushed directly to `main` instead of creating a PR
- Emergency hotfix needed immediately
- GitHub Actions is down

**Steps:**

1. **Commit and push your changes:**
   ```bash
   git add .
   git commit -m "Your changes"
   git push origin main
   ```

2. **Copy files to the Ubuntu server:**
   ```bash
   # Copy HTML/CSS/JS changes
   scp html/prod/header.html andrew@192.168.2.10:/home/andrew/web_server/html/prod/
   scp html/prod/index.html andrew@192.168.2.10:/home/andrew/web_server/html/prod/
   scp html/prod/js/includes.js andrew@192.168.2.10:/home/andrew/web_server/html/prod/js/
   scp html/prod/css/style.css andrew@192.168.2.10:/home/andrew/web_server/html/prod/css/
   
   # If nginx config changed
   scp nginx/conf.d/prod.conf andrew@192.168.2.10:/home/andrew/web_server/nginx/conf.d/
   scp nginx/conf.d/000-bareip.conf andrew@192.168.2.10:/home/andrew/web_server/nginx/conf.d/
   ```

3. **Restart containers on the server:**
   ```bash
   ssh andrew@192.168.2.10 'docker restart nginx-proxy nginx-prod'
   ```

4. **Verify deployment:**
   ```bash
   # Check site loads
   curl -sk https://mitchellnet.local/ | grep -i "<title>"
   
   # Or open in browser
   open https://mitchellnet.local
   ```

**Pro tip:** You can combine steps 2 and 3:
```bash
scp html/prod/*.html andrew@192.168.2.10:/home/andrew/web_server/html/prod/ && \
ssh andrew@192.168.2.10 'docker restart nginx-prod'
```

**Disadvantages:**
- ⚠️ No automatic backup
- ⚠️ No deployment verification
- ⚠️ Manual rollback if issues occur
- ⚠️ No deployment metadata created

---

## 4. Production Environment

### Infrastructure

| Component | Details |
|-----------|---------|
| **Server** | Ubuntu Server 24.04.2 LTS (iMac 2019) |
| **IP** | 192.168.2.10 |
| **URL** | https://mitchellnet.local |
| **Containers** | nginx-proxy, nginx-prod |
| **Deployment** | /home/andrew/web_server/html/prod/ |

### Directory Structure

```
InternalWebServer/
├── html/prod/              # Production content (you edit this)
│   ├── index.html
│   ├── header.html
│   ├── footer.html
│   ├── version.json        # Auto-generated on deploy
│   ├── css/
│   ├── js/
│   └── img/
├── nginx/conf.d/
│   ├── prod.conf           # Production NGINX config
│   └── 000-bareip.conf
├── docker-compose.yml      # Production containers
├── docker-compose.dev.yml  # Local dev containers
├── Makefile               # Local dev commands
└── .github/workflows/
    └── deploy-prod.yml    # Auto-deployment workflow
```

### Accessing Production

From any device on MitchellNET:
- **URL:** https://prod.mitchellnet.local
- **Deployment Info:** https://prod.mitchellnet.local/version.json

---

## 5. Troubleshooting

### Local Development Issues

**Docker containers won't start:**
```bash
# Check Docker Desktop is running
docker info

# If failed, restart Docker Desktop
# macOS: Click Docker icon → Restart

# Check for port conflicts
lsof -i :80
lsof -i :443

# Nuclear option: clean everything
make nuke
make up
```

**Can't access https://prod.mitchellnet.local:**
```bash
# Verify /etc/hosts entry
cat /etc/hosts | grep mitchellnet

# Should show:
# 127.0.0.1 prod.mitchellnet.local

# Verify containers running
docker ps

# Check nginx config
docker exec nginx-proxy-dev nginx -t
```

**Changes not showing:**
```bash
# Hard refresh browser (clear cache)
# macOS: Cmd+Shift+R

# Restart containers
make down
make up

# Check file was actually changed
cat html/prod/index.html
```

### Production Deployment Issues

**Deployment failed:**
1. Check GitHub Actions logs (Actions tab)
2. Verify Ubuntu server is accessible
3. Check server disk space:
   ```bash
   ssh andrew@192.168.2.10 'df -h'
   ```

**Site not updating:**
```bash
# SSH to server
ssh andrew@192.168.2.10

# Check deployment directory
ls -la /home/andrew/web_server/html/prod/

# Check container
docker ps
docker logs nginx-prod

# Manual restart
docker restart nginx-prod
```

---

## 6. Rollback Procedure

If a deployment causes issues:

1. **SSH to server:**
   ```bash
   ssh andrew@192.168.2.10
   ```

2. **Find latest backup:**
   ```bash
   ls -lt /home/andrew/web_server/backups/
   ```

3. **Restore backup:**
   ```bash
   BACKUP_DIR="/home/andrew/web_server/backups/prod_backup_YYYYMMDD_HHMMSS"
   rsync -av --delete "$BACKUP_DIR/" /home/andrew/web_server/html/prod/
   docker restart nginx-prod
   ```

4. **Verify:**
   ```bash
   curl -sk https://prod.mitchellnet.local/version.json
   ```

---

## 7. System Architecture

### Server Hardware (iMac 2019)
| Component | Details |
|------------|----------|
| **Model** | iMac 2019 (Model Identifier: iMac19,1) |
| **CPU** | 3.1 GHz 6‑core Intel Core i5 |
| **Memory** | 32 GB DDR4 |
| **OS** | Ubuntu Server 24.04.2 LTS |
| **Location** | Electronics Lab (MitchellNET LAN) |
| **Internal IP** | `192.168.2.10` |

---

### Core Docker Services

| Container | Purpose | Port |
|------------|----------|------|
| `nginx-proxy` | HTTPS reverse proxy (SSL termination) | 443 |
| `nginx-prod` | Production web site | proxied |
| `nginx-test` | Test web site | proxied |
| `mosquitto` | MQTT Broker | 1883/9001 |
| `grafana` | Monitoring UI | 3000 |
| `prometheus` | Metrics collector | 9090 |
| `node-exporter` | System metrics | 9100 |
| `snmp-exporter` | SNMP devices | 9116 |
| `blackbox-exporter` | Ping/HTTP checks | 9115 |
| `librenms` | SNMP monitoring frontend | 8000 |
| `influxdb` | Time‑series DB | 8086 |
| `telegraf` | Docker metrics collector | — |

---

### Monitoring Stack

**Network Monitoring Dashboard Guide Integration**  

MitchellNET’s monitoring stack provides real‑time visibility into system health, network devices, and service availability.  

**Components:**
- **Prometheus:** scrapes metrics every 15 s from exporters and stores them locally ([http://192.168.2.10:9090](http://192.168.2.10:9090))  
- **Grafana:** visualizes data from Prometheus and InfluxDB ([http://192.168.2.10:3000](http://192.168.2.10:3000))  
- **Node Exporter:** reports host metrics (CPU, RAM, disk, network)  
- **SNMP Exporter:** monitors routers, switches, printers, IoT devices via SNMP  
- **Blackbox Exporter:** performs ICMP ping and HTTP probe checks  

**Sample SNMP Devices Monitored:**  
| Device | IP | Description |  
|---------|----|--------------|  
| Bell Home Hub 3000 | 192.168.2.1 | Main gateway |  
| TP‑Link AC1200 | 192.168.2.2 | Wi‑Fi AP (A6) |  
| TP‑Link AC1750 | 192.168.2.3 | Wi‑Fi AP (C7) |  
| Wavlink AC1200 | 192.168.2.4 | Repeater |  
| iMac Server | 192.168.2.10 | Host system |  
| Raspberry Pi 4 | 192.168.2.21 | IoT node |  
| Tormach 770 S3 | 192.168.2.47 | CNC Mill |  
| Brother MFC‑J5855DW | 192.168.2.179 | Printer |  
| Bambu Labs X1 Carbon | 192.168.2.92 | 3D Printer |  

**Example Dashboards:**
- Node Exporter Overview → CPU/memory stats   
- SNMP Devices Status → Interface traffic & uptime  
- Network Reachability → Ping latency (color‑coded green/yellow/red)

---

### Web Server & Reverse Proxy

Subdomains and routing: `prod.mitchellnet.local` and `test.mitchellnet.local` served through `nginx-proxy` container.  

Local DNS: `192.168.2.10 prod.mitchellnet.local test.mitchellnet.local`

---

### Development Environment (Mac Studio)

| Component | Details |
|------------|----------|
| **OS** | macOS Sonoma |
| **IDE** | Visual Studio Code |
| **Repo** | [theAgingApprentice/InternalWebServer](https://github.com/theAgingApprentice/InternalWebServer) |
| **Runner** | Self‑hosted `imac-server-runner` |
| **SSH Keys** | Stored in `~/.ssh`, registered as GitHub secrets |

Branching model: `develop` → Test / `main` → Production  

---

## 3. Setup & Configuration

*(…content from previous readme on Docker setup, SSL, and monitoring integration retained…)*  

---

## 4. Deployment Workflow

- Push to `develop` → Deploy to Test  
- Merge to `main` → Promote to Production  
- Executed through GitHub Actions self‑hosted runner  

---

## 10. Developer Documentation

### Developer Notes

This section summarizes the developer setup and workflow for the MitchellNET Internal Web Server.  

**Environment:**  
- Mac Studio for development (Visual Studio Code + Git)  
- Ubuntu 2019 iMac for deployment (Test and Production Docker containers)  

**Branch Workflow:**  
1. Branch from `develop` → implement feature → commit and push.  
2. GitHub Actions deploys to Test environment (`/html/test`).  
3. After verification, merge `develop` → `main` to promote to Production (`/html/prod`).  

**SSH and Runner Setup:**  
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
ssh-copy-id andrew@192.168.2.10
./setup-runner.sh  # reinstall GitHub runner if needed
```

**Common Commands:**  
```bash
sudo docker ps
sudo docker restart nginx-test
sudo docker logs nginx-prod
```

**Tips:**  
- Never branch from `main`.  
- Keep GitHub secrets updated (`DEPLOY_USER`, `DEPLOY_PATH`, etc.).  
- Use `curl -k https://192.168.2.10/test` to verify test deployments.  

---

### Developer Quick Reference

| Environment | Location | Purpose |  
|--------------|-----------|----------|  
| Development | 💻 Mac Studio | Local development |  
| Test | 🧪 Ubuntu iMac (`nginx-test`) | Auto‑deploy from `develop` |  
| Production | 🚀 Ubuntu iMac (`nginx-prod`) | Manual promotion |  
| GitHub Repo | 🌐 GitHub | Source control & CI/CD |  

**Typical Workflow:**  
```bash
git checkout develop
git pull
git add .
git commit -m "Update content"
git push origin develop  # Deploys to test
```

**Promote to Production:**  
- Manual GitHub Action → “Promote to Production”  
- Verifies content, backs up, and updates `/html/prod`  

**Verification:**  
```bash
curl -k https://192.168.2.10/test
curl -k https://192.168.2.10
```

**Container Checks:**  
```bash
docker exec nginx-prod grep title /usr/share/nginx/html/index.html
docker exec nginx-test grep title /usr/share/nginx/html/index.html
```

**Diagram:**  
```mermaid
flowchart TD
A[Local Dev (Mac Studio)] --> |Push to develop| B[GitHub Repository]
B --> |Auto Deploy| C[Test Server (Ubuntu)]
C --> |Verify OK| D[Promote to Production]
D --> E[Production Server (Ubuntu)]
```

---

© 2025 TheAgingApprentice — Internal Documentation (MitchellNET)

---

### Docker Services (Simplified)

**For Web Server:**
| Container | Purpose | Port |
|-----------|---------|------|
| `nginx-proxy` | HTTPS reverse proxy (SSL termination) | 443 |
| `nginx-prod` | Production web server | proxied |

**Note:** This README focuses on the web server deployment. The broader MitchellNET infrastructure includes additional services (MQTT, Prometheus, Grafana, etc.) documented separately.

---

### Useful Commands

**Local Development:**
```bash
# Start local containers
make up

# View logs
make logs

# Reload nginx config
make reload

# Stop containers
make down

# Complete cleanup
make nuke
```

**Production Server (SSH to 192.168.2.10):**
```bash
# Check containers
docker ps

# View logs
docker logs nginx-prod
docker logs nginx-proxy

# Restart
docker restart nginx-prod

# Check deployment
cat /home/andrew/web_server/html/prod/version.json
```

---

## 8. Custom Applications

InternalWebServer supports custom full-stack applications with HTML/JavaScript/CSS frontends and Python backends, integrated with MariaDB databases.

### Fitness Tracker App

A full-stack fitness tracking application demonstrating the complete development workflow.

**Features:**
- HTML/CSS/JavaScript frontend
- Python Flask REST API backend
- MariaDB database integration
- Separate dev/production databases
- Docker containerized deployment

**Documentation & Access:**
- **Setup Guide:** [backend/fitnessTracker/README.md](backend/fitnessTracker/README.md)
- **Frontend:** [html/prod/fitnessTracker/index.html](html/prod/fitnessTracker/index.html)
- **Live App:** https://mitchellnet.local/fitnessTracker/ (when deployed)
- **Backend API:** http://localhost:5000/api (production) or http://localhost:5001/api (dev)

**Quick Start:**
```bash
# Development
docker-compose -f docker-compose.dev.yml up -d

# Access at https://mitchellnet.dev.local/fitnessTracker/
```

### Adding Your Own Apps

The same pattern can be used for additional custom applications:
1. Create backend directory: `backend/yourapp/`
2. Create frontend directory: `html/prod/yourapp/`
3. Add services to `docker-compose.yml` and `docker-compose.dev.yml`
4. Use separate databases (e.g., `yourapp_dev` and `yourapp_prod`)

See the [Fitness Tracker README](backend/fitnessTracker/README.md) for the complete architecture and setup instructions.

---

## 9. SSL Certificate Setup for iOS Devices

The production server uses an **mkcert**-generated SSL certificate trusted by the Mac's keychain. iOS devices still require the legacy CA cert to be installed manually (see below).

### Certificate Details

- **Active cert on server:** `/home/andrew/web_server/nginx/certs/server.crt` (and `server.key`)
- **Tool used:** mkcert (Mac keychain-trusted — no browser warnings on Mac)
- **Legacy CA cert (iOS use):** `sslCertificates/mitchellnet-ca.crt` (in this repository)
- **Valid Domains/IPs:** 
  - mitchellnet.local
  - 192.168.2.10
- **Expires:** July 2028

### Installing Certificate on iOS

#### Step 1: Transfer Certificate to iOS Device

Choose one method:

**Option A: AirDrop (Easiest)**
1. On your Mac, locate `sslCertificates/mitchellnet-ca.crt`
2. Right-click → Share → AirDrop
3. Send to your iPhone/iPad

**Option B: Email**
1. Email `sslCertificates/mitchellnet-ca.crt` to yourself
2. Open email on iOS device
3. Tap the attachment

**Option C: Convert to Configuration Profile (Most Reliable)**
```bash
# On your Mac, from project root:
base64 -i sslCertificates/mitchellnet-ca.crt | tr -d '\n' > /tmp/cert_base64.txt

# Create a .mobileconfig file (iOS configuration profile)
# See sslCertificates/create-ios-profile.sh for automation
```

#### Step 2: Install Certificate

1. When you open/tap the certificate, iOS shows **"Profile Downloaded"**
2. Go to **Settings** on iOS device
3. Tap **"Profile Downloaded"** (appears near top, under your Apple ID)
4. Tap **"Install"** (top right)
5. Enter device passcode
6. Tap **"Install"** again (warning appears)
7. Tap **"Install"** a third time to confirm
8. Tap **"Done"**

#### Step 3: Trust the Certificate (CRITICAL)

This step is required for Safari to accept the certificate:

1. Go to **Settings**
2. **General**
3. **About**
4. Scroll down to **"Certificate Trust Settings"**
5. Find **"MitchellNet Root CA"**
6. **Toggle it ON** (turn green)
7. Tap **"Continue"** when warned

### Accessing the Website

After certificate installation:

**On Mac (Safari/Chrome/Edge):**
- ✅ `https://mitchellnet.local`
- ✅ `https://192.168.2.10`

**On iPhone/iPad (Safari):**
- ✅ `https://192.168.2.10` (recommended)
- ❌ `https://mitchellnet.local` (DNS not configured for iOS)

**Why the difference?**
- Mac has a hosts file that resolves `mitchellnet.local` → `192.168.2.10`
- iOS devices cannot resolve `mitchellnet.local` without additional DNS configuration
- **Solution:** Use the IP address `https://192.168.2.10` on iOS devices

### Renewing the Certificate

When the cert expires (July 2028) or a browser update breaks trust again, do **only these steps** — no nginx config changes are needed:

```bash
# On your Mac: generate new mkcert cert (creates files in current directory)
mkcert mitchellnet.local 192.168.2.10

# Copy cert files to the server
scp ~/mitchellnet.local+1.pem ~/mitchellnet.local+1-key.pem andrew@192.168.2.10:/home/andrew/web_server/nginx/certs/

# On the server: rename to the expected filenames and restart nginx
ssh andrew@192.168.2.10 "cd /home/andrew/web_server/nginx/certs && \
  mv mitchellnet.local+1.pem server.crt && \
  mv mitchellnet.local+1-key.pem server.key && \
  cd /home/andrew/web_server && docker compose restart nginx-proxy"
```

> **Why mkcert?** After a browser update, Edge stopped trusting the old self-signed OpenSSL CA cert. mkcert registers its own root CA with the Mac's system keychain at install time, so certs it generates are automatically trusted by Safari, Chrome, and Edge without any manual keychain steps.

> **If mkcert is not installed on your Mac:**
> ```bash
> brew install mkcert
> mkcert -install   # registers mkcert CA with macOS keychain (one-time)
> ```

### Production Server Nginx Configuration

For the certificate to work with both domain names and IP addresses, ensure nginx is configured properly:

**Key Configuration Files:**
- `/home/andrew/web_server/nginx/conf.d/prod.conf` - Main production config
- `/home/andrew/web_server/nginx/conf.d/000-bareip.conf` - Bare IP access config

Both files reference the mkcert cert at:
- `ssl_certificate     /etc/nginx/ssl/server.crt;`
- `ssl_certificate_key /etc/nginx/ssl/server.key;`

(The cert files live on the host at `/home/andrew/web_server/nginx/certs/` and are volume-mounted into the container as `/etc/nginx/ssl/`.)

**Example prod.conf configuration:**
```nginx
server {
    listen 443 ssl;
    server_name mitchellnet.local 192.168.2.10;  # Both domain and IP
    
    ssl_certificate     /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;
    
    # ... rest of configuration
}
```

### Troubleshooting iOS Access

**Problem:** iOS Safari shows "Cannot connect to server" or infinite loading

**Solution:** 
1. Verify certificate is installed and trusted in Certificate Trust Settings
2. Use `https://192.168.2.10` instead of domain name
3. Clear Safari cache: Settings → Safari → Clear History and Website Data
4. Try in Private Browsing mode first
5. Check server logs: `ssh andrew@192.168.2.10 "docker logs nginx-proxy --tail 50"`

**Problem:** Certificate not appearing in Certificate Trust Settings

**Solution:**
1. Remove old certificate profiles: Settings → General → VPN & Device Management
2. Use the `.mobileconfig` format instead of raw `.crt` file
3. Ensure certificate has `CA:TRUE` flag (required for iOS to trust it)

---

## Additional Resources

- **Cleanup Guide:** [CLEANUP.md](CLEANUP.md) - Remove old dev/test infrastructure
- **Archived Documentation:** [archive/](archive/) - Original complex setup docs  
- **GitHub Actions Workflow:** [.github/workflows/deploy-prod.yml](.github/workflows/deploy-prod.yml)

---

## Quick Start Checklist

**Local Development Setup:**
- [ ] Docker Desktop installed and running
- [ ] Repository cloned locally  
- [ ] `/etc/hosts` configured with `127.0.0.1 prod.mitchellnet.local`
- [ ] Can run `make up` successfully
- [ ] Can access https://prod.mitchellnet.local in browser

**First Deployment:**
- [ ] Created feature branch
- [ ] Made changes in `html/prod/`
- [ ] Tested locally with `make up`
- [ ] Committed and pushed to GitHub
- [ ] Created Pull Request to `main`
- [ ] Merged PR and verified auto-deployment

---

**Questions or Issues?** Check the [Troubleshooting](#5-troubleshooting) section above.

---

## 10. SSL Certificate Setup for macOS Devices

The production server now uses an **mkcert**-generated certificate. mkcert registers its own root CA with the Mac's system keychain at install time, so Safari, Chrome, and Edge all trust the cert automatically — no manual keychain steps needed.

> **Already working?** If your Mac browsers show a lock icon at https://mitchellnet.local and https://192.168.2.10, nothing to do here.

### One-Time Mac Setup (if mkcert not yet installed)

```bash
brew install mkcert
mkcert -install   # adds mkcert's CA to macOS Keychain — one time only
```

After this, any cert generated by `mkcert` on this Mac is automatically trusted by Safari, Chrome, and Edge.

### Verification

```bash
# Verify SSL connection to the server (should show "Verify return code: 0 (ok)")
openssl s_client -connect 192.168.2.10:443 < /dev/null 2>/dev/null | grep -E "Verify return|subject"
```

**Test in browser:**
1. Open Safari, Chrome, or Edge
2. Navigate to https://mitchellnet.local or https://192.168.2.10
3. The address bar should show a lock icon with no warnings

### Troubleshooting macOS Certificate Issues

**Problem:** Edge (or another browser) suddenly shows "Not Secure" after a browser update

**Solution:** The cert is probably still valid but the browser's trust model changed. Renew the cert using mkcert — see the "Renewing the Certificate" section above (section 9). This happened in April 2026 after an Edge update broke trust for the old self-signed CA.

**Problem:** Browser shows "Not Secure" and mkcert is installed

**Solutions:**
1. Check mkcert CA is still in Keychain: `mkcert -CAROOT` then verify that path exists
2. Re-run `mkcert -install` to re-register the CA
3. Renew the server cert (see section 9 — Renewing the Certificate)
4. Clear browser cache and restart the browser

**Problem:** Firefox still shows warnings

**Solutions:**
- Firefox uses its own certificate store, separate from macOS Keychain
- Option 1: Accept the certificate exception in Firefox (click "Advanced" → "Accept Risk")
- Option 2: Import the mkcert CA into Firefox:
  1. Find the mkcert CA file: `mkcert -CAROOT` (shows directory; look for `rootCA.pem`)
  2. Firefox → Preferences → Privacy & Security
  3. Scroll to **Certificates** → Click **View Certificates**
  4. Go to **Authorities** tab → **Import**
  5. Select `rootCA.pem` from the mkcert CA root directory
  6. Check "Trust this CA to identify websites" → **OK**

---

## 11. Connected Services

The following services are currently routed through the `nginx-proxy` container. All upstream resolution happens by Docker container name within the shared Docker networks.

| URL Path | Container Name | Internal Port | Notes |
|----------|---------------|--------------|-------|
| `/` | `nginx-prod` | 80 | Static web UI (HTML/CSS/JS) |
| `/fitness/` | `fitness-tracker-backend-prod` | 5000 | Fitness Tracker REST API — pending extraction to a dedicated path |
| `/api/bench/` | `bench-instrument-service` | 8000 | Bench Instrument Service (BIS) — waveform capture and multimeter logging |

> **Note:** The fitness tracker backend is currently served at `/api/` in the NGINX configuration. The `/fitness/` path shown above reflects the planned dedicated route once the service is extracted from the shared `/api/` prefix.

For full details on per-location proxy settings and timeout rationale, see [docs/nginx-routing.md](docs/nginx-routing.md).

---

## 12. Network

### mitchellnet External Docker Network

The `nginx-proxy` container must be connected to the `mitchellnet` external Docker network so it can resolve upstream service hostnames (e.g., `bench-instrument-service`) that run in other Docker Compose stacks. This is configured in [docker-compose.yml](docker-compose.yml):

```yaml
networks:
  mitchellnet:
    external: true
```

**The `mitchellnet` network must exist on the host before deploying.** Create it once with:

```bash
docker network create mitchellnet
```

If the network does not exist, `docker compose up` will fail with a network not found error and `nginx-proxy` will be unable to reach any service outside the local `webnet`.

### webnet Internal Network

The `webnet` network (`web_server_webnet`) is an external network used for communication between containers in this Compose stack (e.g., `nginx-proxy` → `nginx-prod`, `nginx-proxy` → `fitness-tracker-backend-prod`).

---

