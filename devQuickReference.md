# Developer Quick Reference — MitchellNET Internal Web

This guide summarizes the workflow for updating, testing, and promoting changes to the MitchellNET internal web system, with the latest deployment improvements and safety features.

---

## 🖥️ Environments Overview

| Environment | Location | Purpose |
|--------------|-----------|----------|
| **Development** | 💻 Mac Studio (local dev) | Make and test code changes locally |
| **Test** | 🧪 Ubuntu 2019 iMac (`nginx-test`) | Automatically deploys updates from the GitHub `develop` branch |
| **Production** | 🚀 Ubuntu 2019 iMac (`nginx-prod`) | Live internal site, updated only via the Promote to Production workflow |
| **GitHub Repository** | 🌐 GitHub Web GUI | Source control, Actions automation, and environment management |

---

## 🔄 End-to-End Workflow

### 1. Local Development (Mac Studio)
- **Branch:** `develop`
- **Purpose:** Build and test new site changes locally.

```bash
# Switch to the develop branch
git checkout develop

# Pull latest updates
git pull

# Make code changes (HTML, CSS, etc.)
git add .
git commit -m "Update layout or content"

# Push to GitHub to trigger Deploy to Test
git push origin develop
```

---

### 2. Deploy to Test (Ubuntu Self-Hosted Runner)
- **Workflow:** `.github/workflows/deploy-test.yml`
- **Triggered by:** Push to `develop`
- **Runs on:** The Ubuntu 2019 iMac server
- **Result:** Updates the `/html/test` folder and restarts the `nginx-test` container.

#### 🧠 What’s New
- **Local Execution:** Runs directly on the server (no SSH or internet access required).  
- **Automatic Verification:** Checks that the container responds correctly at `https://192.168.2.10/test`.  
- **Future-Proof:** This structure enables rollback and retention support, similar to production.

🧩 **Verification**
- Visit `https://192.168.2.10/test`
- Confirm the **TEST ENVIRONMENT** banner appears correctly.

---

### 3. Promote to Production (Manual GitHub Action)
- **Workflow:** `.github/workflows/promote-prod.yml`
- **Triggered by:** Manual run from GitHub → Actions tab → “Promote to Production”
- **Runs on:** Ubuntu self-hosted runner
- **Result:** Promotes validated content from `/html/test` to `/html/prod`.

#### ✅ Safeguards Added
- **Container verification:** Ensures `/prod` contains “Production Environment.”  
- **Automatic rollback:** Restores from backup if verification fails.  
- **Backup retention:** Automatically deletes backups older than 7 days.  
- **Email step:** Temporarily commented out (secrets not configured).

🧩 **Verification**
```bash
curl -k https://192.168.2.10
```
You should see **Production Environment** in the banner and `<title>`.

---

### 4. Container Checks (Ubuntu Server)

```bash
# Verify environment banners in HTML content
docker exec nginx-prod grep title /usr/share/nginx/html/index.html
docker exec nginx-test grep title /usr/share/nginx/html/index.html
```

✅ `nginx-prod` → “Production Environment”  
🚧 `nginx-test` → “Test Environment”

---

### 5. Branch Maintenance (GitHub + Local)
- Keep `develop` as your working/testing branch.
- After promoting to production, **do not delete `develop`** — continue using it for the next cycle.

Optional backup:
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
    A[💻 Local Dev (Mac Studio)] -->|Push develop| B[🌐 GitHub Repo]
    B -->|Deploy to Test| C[🧪 nginx-test (Ubuntu)]
    C -->|Verify changes| D[🚀 Promote to Production Workflow]
    D --> E[🌐 nginx-prod (Ubuntu)]
    E -->|Live site verified| F[✅ Production Confirmed]
```

---

## 📋 Key Commands Summary

| Task | Command | Location |
|------|----------|-----------|
| Pull latest | `git pull` | Mac Studio |
| Commit & push | `git add . && git commit -m "msg" && git push` | Mac Studio |
| Check test | `curl -k https://192.168.2.10/test` | Any system |
| Promote to prod | GitHub Actions → “Promote to Production” | GitHub |
| Verify prod | `curl -k https://192.168.2.10` | Any system |
| Inspect containers | `docker ps && docker exec <container> ls /usr/share/nginx/html` | Ubuntu server |

---

# Related Files

- [README.md](README.md)
- [DeveloperNotes.md](DeveloperNotes.md)
