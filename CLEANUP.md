# Cleanup Guide - Removing Old Dev/Test Infrastructure

This guide helps you safely remove the old development and test environment files now that you've simplified to a single production environment.

---

## 🗂️ Files and Directories to Remove

### 1. Old Environment Directories

```bash
# Remove development directory
rm -rf html/dev/

# Remove test directory  
rm -rf html/test/
```

**What this removes:** The separate dev and test HTML content directories that are no longer used.

---

### 2. Old GitHub Actions Workflows

```bash
# Remove test deployment workflow
rm -f .github/workflows/deploy-test.yml

# Remove manual production promotion workflow
rm -f .github/workflows/promote-prod.yml
```

**What this removes:** Old workflows that deployed to test environment and manually promoted to production.

---

### 3. Old NGINX Configuration

```bash
# Remove test environment NGINX config
rm -f nginx/conf.d/test.conf
```

**What this removes:** NGINX configuration for test.mitchellnet.local that's no longer needed.

---

### 4. Old Environment Banners

```bash
# Remove test environment banner
rm -f includes/test-env-banner.html
```

**What this removes:** The banner that indicated test environment. You may want to update or remove `includes/prod-env-banner.html` as well since there's only one environment now.

---

### 5. Old Documentation (Optional)

Move old documentation to archive:

```bash
# Already in archive directory - just verify
ls -la archive/

# You can keep these for reference, or delete:
# rm -f archive/README-DEV.md
# rm -f archive/devQuickReference.md
# rm -f archive/DeveloperNotes.md
```

**What this does:** Keeps historical documentation in archive for reference.

---

### 6. NGINX Backup Snapshots (Optional)

```bash
# Remove old NGINX configuration backups
rm -rf nginx/_final_backup_2025-10-18_232101/
rm -rf nginx/_snap_2025-10-18_233206/
rm -rf nginx/_snap_2025-10-18_233601/
```

**What this removes:** Old NGINX configuration snapshots. Only do this if you're confident you don't need them.

---

## 🔄 One-Command Cleanup

If you want to clean everything up at once:

```bash
#!/bin/bash
# cleanup.sh - Remove old dev/test infrastructure

echo "🧹 Cleaning up old dev/test infrastructure..."

# Remove environment directories
echo "Removing html/dev and html/test..."
rm -rf html/dev/ html/test/

# Remove old workflows
echo "Removing old GitHub Actions workflows..."
rm -f .github/workflows/deploy-test.yml
rm -f .github/workflows/promote-prod.yml

# Remove test NGINX config
echo "Removing test NGINX configuration..."
rm -f nginx/conf.d/test.conf

# Remove test banner
echo "Removing test environment banner..."
rm -f includes/test-env-banner.html

# Optional: Remove NGINX backups
read -p "Remove NGINX backup snapshots? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing NGINX backups..."
    rm -rf nginx/_final_backup_2025-10-18_232101/
    rm -rf nginx/_snap_2025-10-18_233206/
    rm -rf nginx/_snap_2025-10-18_233601/
fi

echo "✅ Cleanup complete!"
echo ""
echo "Next steps:"
echo "1. Review changes: git status"
echo "2. Commit changes: git add -A && git commit -m 'Remove old dev/test infrastructure'"
echo "3. Push to repository: git push origin main"
```

Save this as `cleanup.sh` and run:

```bash
chmod +x cleanup.sh
./cleanup.sh
```

---

## 🐳 Docker Cleanup

After removing files, clean up Docker:

```bash
# Stop and remove old test container (if running)
docker stop nginx-test 2>/dev/null || true
docker rm nginx-test 2>/dev/null || true

# Restart the remaining services with updated configuration
docker compose down
docker compose up -d

# Verify only production services are running
docker ps
# Should show: nginx-proxy and nginx-prod only
```

---

## ✅ Verification Checklist

After cleanup, verify everything works:

- [ ] Only `nginx-proxy` and `nginx-prod` containers running
- [ ] `html/prod/` directory exists with content
- [ ] https://prod.mitchellnet.local accessible
- [ ] GitHub Actions workflow at `.github/workflows/deploy-prod.yml` exists
- [ ] `docker-compose.yml` only references nginx-prod (no nginx-test)
- [ ] NGINX config in `nginx/conf.d/` only has `prod.conf` and `000-bareip.conf`

---

## 🔙 Backup Before Cleanup

**Important:** Before running cleanup, create a backup:

```bash
# Create a backup of the entire project
cd /Users/andrewmitchell/Documents/visualStudioCode/html/projects/
tar -czf InternalWebServer-backup-$(date +%Y%m%d).tar.gz InternalWebServer/

# Or just backup the directories you're removing
cd InternalWebServer
tar -czf old-env-backup-$(date +%Y%m%d).tar.gz html/dev/ html/test/ nginx/_snap* nginx/_final*
```

This way you can always restore if needed.

---

## 📝 Git Commit

After cleanup:

```bash
# Review what will be removed
git status

# Stage all changes
git add -A

# Commit
git commit -m "Simplify to single production environment

- Remove dev and test directories
- Remove old GitHub Actions workflows
- Remove test NGINX configuration
- Update docker-compose to single prod service
- Add new PR-based deployment workflow"

# Push to repository
git push origin main
```

---

## 🚨 What NOT to Remove

Keep these important files:

- ✅ `html/prod/` - Your production content
- ✅ `docker-compose.yml` - Updated production compose file
- ✅ `nginx/conf.d/prod.conf` - Production NGINX config
- ✅ `nginx/conf.d/000-bareip.conf` - Bare IP redirect
- ✅ `.github/workflows/deploy-prod.yml` - New deployment workflow
- ✅ `includes/` directory - May contain production includes
- ✅ `ssl/` directory - SSL certificates
- ✅ `Makefile` - Still useful for local dev
- ✅ `docker-compose.dev.yml` - Useful for local testing

---

## 🎉 All Done!

After cleanup, you'll have a much simpler structure:

```
InternalWebServer/
├── .github/workflows/
│   └── deploy-prod.yml          # ✨ New PR-based deployment
├── html/prod/                   # Only production content
├── nginx/conf.d/
│   ├── prod.conf                # Production only
│   └── 000-bareip.conf
├── docker-compose.yml           # Simplified - prod only
├── README-SIMPLIFIED.md         # New documentation
└── CLEANUP.md                   # This file
```

**Much cleaner!** 🎊
