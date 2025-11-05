# Developer Notes — MitchellNET Internal Web Server

This document provides detailed guidance for developers contributing to the MitchellNET internal website. It covers the local development environment setup, branching strategy, GitHub workflows, and interaction with the Ubuntu host server.

---

## Table of Contents
1. [Overview](#overview)
2. [Development Environment Setup](#development-environment-setup)
3. [Repository and Branching Strategy](#repository-and-branching-strategy)
4. [Workflow Summary](#workflow-summary)
5. [Deploying to Test Environment](#deploying-to-test-environment)
6. [Promoting to Production](#promoting-to-production)
7. [Monitoring and Debugging](#monitoring-and-debugging)
8. [Server Directory Structure](#server-directory-structure)
9. [Tips for Future Developers](#tips-for-future-developers)
10. [Main README file](README.md)
11. [Dev quick reference](devQuickReference.md)
---

## Overview

The **MitchellNET Internal Web Server** is a self-contained environment consisting of:

- **Development Machine**: Mac Studio (macOS) running Visual Studio Code.
- **Repository**: Hosted on GitHub under [`theAgingApprentice/InternalWebServer`](https://github.com/theAgingApprentice/InternalWebServer).
- **Deployment Target**: 2019 iMac running **Ubuntu Server 24.04.2 LTS**, hosting Docker containers for test and production environments.

Communication between environments is secured with SSH and a self-signed HTTPS certificate.

---

## Development Environment Setup

To contribute or test locally:

1. **Install Git and Visual Studio Code**
   ```bash
   brew install git
   ```

2. **Clone the Repository**
   ```bash
   git clone https://github.com/theAgingApprentice/InternalWebServer.git
   cd InternalWebServer
   ```

3. **Create SSH Keys (if needed)**
   ```bash
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```
   Add your public key to the Ubuntu server’s `~/.ssh/authorized_keys` file for passwordless access.

4. **Set Up the Self-Hosted Runner (if needed)**
   The Ubuntu host already has a runner (`imac-server-runner`) registered, but you can reinstall it by running:
   ```bash
   ./setup-runner.sh
   ```

---

## Repository and Branching Strategy

We follow a **main/develop** branching model:

| Branch | Purpose | Deployment |
|---------|----------|-------------|
| `main` | Stable production-ready code | Deployed to production |
| `develop` | In-progress development work | Deployed to test |

### Branch Workflow

1. Create a new branch from `develop` for your feature or fix:
   ```bash
   git checkout develop
   git pull
   git checkout -b feature/your-feature-name
   ```

2. When finished, push and open a **Pull Request (PR)** into `develop`:
   ```bash
   git push origin feature/your-feature-name
   ```

3. After review and merge, the GitHub Actions workflow automatically deploys to the **test environment**.

4. When ready to release, create a PR from `develop` → `main` to promote to production.

---

## Workflow Summary

GitHub Actions provides **two workflows**, located in `.github/workflows/`:

| Workflow | File | Trigger | Description |
|-----------|------|----------|-------------|
| **Deploy to Test** | `deploy-test.yml` | On push to `develop` | Copies site files to `/html/test/` and verifies with HTTPS curl |
| **Promote to Production** | `promote-prod.yml` | Manual (workflow_dispatch) | Copies test content to `/html/prod/` and restarts Nginx |

---

## Deploying to Test Environment

When you push to the `develop` branch, GitHub Actions will:

1. Check out your code.
2. SSH into the Ubuntu server using the configured GitHub Secrets.
3. Sync the `html/test` directory using `rsync`.
4. Restart the `nginx-test` container.
5. Verify that the test site responds with a `200 OK` via HTTPS.

You can view the workflow status in the **GitHub Actions** tab under *“Deploy to Test”*.

---

## Promoting to Production

Once your code passes verification in test:

1. Merge `develop` into `main` via Pull Request on GitHub.
2. Manually trigger the **Promote to Production** workflow:
   - Navigate to **Actions → Promote to Production → Run workflow**.
3. The workflow will:
   - Copy all files from `/html/test/` to `/html/prod/` on the Ubuntu server.
   - Restart the production container (`nginx-prod`).

---

## Monitoring and Debugging

### On the Ubuntu Server (2019 iMac)

SSH into the host:
```bash
ssh andrew@192.168.2.10
```

Check running Docker containers:
```bash
sudo docker ps
```

Restart a specific container:
```bash
sudo docker restart nginx-test
sudo docker restart nginx-prod
```

View logs:
```bash
sudo docker logs nginx-test
sudo docker logs nginx-prod
```

### On the Developer Mac

From your project directory:
```bash
git status
git branch
git log --oneline
```

### On GitHub

- **Actions Tab** → See workflow results (green = success, red = failed).
- **Pull Requests Tab** → Review code before merging to main or develop.

---

## Server Directory Structure

```
/home/andrew/web_server/html/
├── prod/
│   └── index.html     # Production content
├── test/
│   └── index.html     # Test environment content
└── proxy/
    ├── certs/
    ├── conf.d/
    └── docker-compose.yml
```

---

## Tips for Future Developers

- Always branch from `develop`, **never from `main`**.
- Ensure all SSH keys are properly configured in both GitHub and the Ubuntu server.
- Keep secrets updated in the GitHub repository under **Settings → Secrets and variables → Actions**.
- Use `curl -k https://192.168.2.10/test` to manually verify test deployments.
- Document all changes in the Pull Request description for traceability.

---

**Maintainer:** Andrew Mitchell  
**Project Repository:** [theAgingApprentice/InternalWebServer](https://github.com/theAgingApprentice/InternalWebServer)
