# InternalWebServer - Production Deployment

> **Author:** Andrew Mitchell (TheAgingApprentice)  
> **System:** Ubuntu Server 24.04.2 LTS (iMac19,1, 2019 iMac)  
> **Deployment:** Simplified single-branch workflow with GitHub Actions  
> **Last Updated:** December 21, 2025

---

## 📑 Table of Contents
1. [Overview](#overview)
2. [Local Development Setup](#local-development-setup)
   - [Prerequisites](#prerequisites)
   - [Running Docker Locally](#running-docker-locally)
   - [Testing Changes Locally](#testing-changes-locally)
3. [Deployment Workflow](#deployment-workflow)
   - [Making Changes](#making-changes)
   - [Pull Request Deployment](#pull-request-deployment)
4. [Production Environment](#production-environment)
5. [Troubleshooting](#troubleshooting)
6. [Rollback Procedure](#rollback-procedure)
7. [System Architecture](#system-architecture)

---

## 1. Overview

**InternalWebServer** is a simplified NGINX-based web hosting solution for MitchellNET. This repository uses a streamlined deployment process:

✅ **Single Branch:** Work directly on `main` branch or feature branches  
✅ **Automated Deployment:** Merging PR to `main` auto-deploys to production  
✅ **Local Testing:** Test changes locally before pushing to GitHub  
✅ **Simple Infrastructure:** Only production environment maintained

**Production URL:** https://mitchellnet.local

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

### Making Changes

#### Standard Workflow (Feature Branch)

1. **Create a feature branch:**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/your-feature-name
   ```

2. **Make changes** in `html/prod/`:
   ```bash
   # Edit your files
   code html/prod/index.html
   ```

3. **Test locally** (see "Testing Changes Locally" above):
   ```bash
   make up
   # View at https://prod.mitchellnet.local
   make down
   ```

4. **Commit and push:**
   ```bash
   git add html/prod/
   git commit -m "Description of your changes"
   git push origin feature/your-feature-name
   ```

5. **Create Pull Request** on GitHub to `main`

6. **Merge PR** → Automatic deployment to production! 🚀

#### Quick Workflow (Direct to Main)

⚠️ Use only for minor changes

```bash
git checkout main
git pull origin main
# Make changes
git add html/prod/
git commit -m "Minor update"
git push origin main
```

This will NOT trigger automatic deployment. Only merged PRs trigger deployment.

### Pull Request Deployment

When you merge a PR to `main`, GitHub Actions automatically:

1. ✅ Checks out merged code
2. 📦 Backs up current production
3. 📝 Creates deployment metadata
4. 🚀 Deploys to Ubuntu server
5. 🔄 Restarts nginx-prod container
6. ✓ Verifies deployment

**Monitor deployment:**
- Go to GitHub → Actions tab
- Watch the "Deploy to Production" workflow

---

## 4. Production Environment

### Infrastructure

| Component | Details |
|-----------|---------|
| **Server** | Ubuntu Server 24.04.2 LTS (iMac 2019) |
| **IP** | 192.168.2.10 |
| **URL** | https://prod.mitchellnet.local |
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

