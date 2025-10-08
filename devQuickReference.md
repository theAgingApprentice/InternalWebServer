# Developer Quick Reference — MitchellNET Internal Web

This guide summarizes the full workflow for updating, testing, and promoting changes to the MitchellNET internal web system.

---

## 🖥️ Environments Overview

| Environment | Location | Purpose |
|--------------|-----------|----------|
| **Development** | 💻 Mac Studio (local dev) | Make and test code changes locally |
| **Test** | 🧪 Ubuntu 2019 iMac (`nginx-test`) | Preview and validate updates deployed from GitHub `develop` branch |
| **Production** | 🚀 Ubuntu 2019 iMac (`nginx-prod`) | Live internal site — only updated through the Promote to Production workflow |
| **GitHub Repository** | 🌐 GitHub Web GUI | Source control, Actions automation, and environment management |

---

## 🔄 End-to-End Workflow

### 1. Local Development (Mac Studio)
- **Environment:** Mac Studio
- **Branch:** `develop`
- **Purpose:** Build and test new site changes before deployment.

```bash
# Switch to the develop branch
git checkout develop

# Pull latest updates
git pull

# Make your code changes locally (HTML, CSS, etc.)
# Then stage and commit your changes
git add .
git commit -m "Update test environment banner and layout"

# Push to GitHub to trigger Deploy to Test
git push origin develop
```

---

### 2. GitHub Deploys to Test (GitHub Actions)
- **Environment:** GitHub Repository
- **Triggered by:** Push to `develop`
- **Action:** `.github/workflows/deploy-test.yml`
- **Result:** Updates the Ubuntu test container (`nginx-test`) automatically.

🧩 **Verification:**
- Visit `https://192.168.2.10/test` from a browser or run:
  ```bash
  curl -k https://192.168.2.10/test
  ```
- Confirm that the new changes appear correctly and the **TEST ENVIRONMENT** banner is visible.

---

### 3. Manual Promote to Production (GitHub Actions)
- **Environment:** GitHub Repository
- **Triggered by:** Manually running **“Promote to Production”** workflow (`.github/workflows/promote-prod.yml`)
- **Action:** Copies validated content from `/html/test` → `/html/prod` in the repo, rebuilds the `nginx-prod` container.

🧩 **Verification:**
- Visit `https://192.168.2.10` or `https://192.168.2.10/prod`
- You should see the **PRODUCTION ENVIRONMENT** banner and the latest approved content.

---

### 4. Post-Promotion Verification (Ubuntu Server)
- **Environment:** 2019 iMac Ubuntu server
- **Confirm content inside the containers:**

```bash
# Check container mounts and HTML
docker exec nginx-prod cat /usr/share/nginx/html/index.html | grep title
docker exec nginx-test cat /usr/share/nginx/html/index.html | grep title
```

✅ `nginx-prod` should show “Production Environment”  
🚧 `nginx-test` should show “Test Environment”

---

### 5. Branch Maintenance (GitHub + Local)
- Keep `develop` as your ongoing feature/testing branch.
- After a successful production promotion, **do not delete `develop`** — reuse it for the next update cycle.

Optionally, you can keep a **backup branch**:
```bash
git checkout develop
git pull
git checkout -b develop-backup
git push origin develop-backup
```

---

## 🧭 Workflow Diagram

```mermaid
flowchart TD
    A[💻 Local Dev (Mac Studio)] -->|Push to develop| B[🌐 GitHub Repo]
    B -->|Auto Deploy| C[🧪 nginx-test (Ubuntu)]
    C -->|Verify OK| D[🚀 Promote to Production Workflow]
    D --> E[🌐 nginx-prod (Ubuntu)]
    E -->|Live site| F[✅ Verified Production]
```

---

## 📋 Summary of Key Commands

| Task | Command | Where |
|------|----------|-------|
| Pull latest dev changes | `git pull` | Mac Studio |
| Commit and push changes | `git add . && git commit -m "msg" && git push` | Mac Studio |
| Verify test deployment | `curl -k https://192.168.2.10/test` | Any system |
| Run production promotion | GitHub Actions → “Promote to Production” | GitHub Web |
| Verify production deployment | `curl -k https://192.168.2.10` | Any system |
| Inspect containers | `docker ps && docker exec <container> ls /usr/share/nginx/html` | Ubuntu server |

# Readme Navigation Links

- [Main README file](README.md)
- [Developer Notes](DeveloperNotes.md)