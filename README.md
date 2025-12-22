# MitchellNET Infrastructure Overview

> **Author:** Andrew Mitchell (TheAgingApprentice)  
> **System:** Ubuntu Server 24.04.2 LTS (iMac19,1, 2019 iMac)  
> **Environment:** Internal Docker-based network stack with web, MQTT, monitoring, and CI/CD integration  
> **Last Updated:** 2025-11-04

---

## 📑 Table of Contents
1. [Overview](#overview)
2. [System Architecture](#system-architecture)
   - [Server Hardware (iMac 2019)](#server-hardware-imac-2019)
   - [Core Docker Services](#core-docker-services)
   - [Monitoring Stack](#monitoring-stack)
   - [Web Server & Reverse Proxy](#web-server--reverse-proxy)
   - [Development Environment (Mac Studio)](#development-environment-mac-studio)
3. [Setup & Configuration](#setup--configuration)
   - [Docker & NGINX Containers](#docker--nginx-containers)
   - [SSL Certificates](#ssl-certificates)
   - [Monitoring Integration](#monitoring-integration)
4. [Deployment Workflow](#deployment-workflow)
   - [Development → Test](#development--test)
   - [Test → Production](#test--production)
5. [Backups & Restoration](#backups--restoration)
6. [Security Practices](#security-practices)
7. [Troubleshooting](#troubleshooting)
8. [Replication & Recovery](#replication--recovery)
9. [References & Useful Commands](#references--useful-commands)
10. [Developer Documentation](#developer-documentation)
    - [Developer Notes](#developer-notes)
    - [Developer Quick Reference](#developer-quick-reference)

---

## 1. Overview

**MitchellNET** is a fully self-contained internal server ecosystem hosted on a **2019 iMac** running Ubuntu Server 24.04.2 LTS.  
It provides:
- Secure HTTPS web hosting via **NGINX reverse proxy**
- Separate **Test** and **Production** subdomains
- **MQTT** message broker for IoT messaging
- **Prometheus + Grafana + LibreNMS + InfluxDB + Telegraf** for monitoring
- Automated deployments via **GitHub Actions** connected to a **Mac Studio** development workstation

---

## 2. System Architecture

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
