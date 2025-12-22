# InternalWebServer - Simplified Deployment

> **Last Updated:** December 21, 2025  
> **Deployment Strategy:** Single branch (main) with GitHub Actions on PR merge

---

## 📋 Overview

This repository has been **simplified** to use a single production environment. The previous dev/test/prod split has been replaced with a streamlined workflow:

- **Single Branch:** `main` is the only active branch
- **Automated Deployment:** Merging pull requests to `main` triggers automatic deployment to production
- **Single Environment:** Only production (`prod.mitchellnet.local`) is maintained

---

## 🚀 Deployment Workflow

### Making Changes

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/my-changes
   ```

2. **Make your changes** in the `html/prod/` directory

3. **Test locally** (optional):
   ```bash
   # Use docker-compose.dev.yml for local testing if needed
   make up
   ```

4. **Commit and push:**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push origin feature/my-changes
   ```

5. **Create a Pull Request** to `main` on GitHub

6. **Merge the PR** - This automatically triggers deployment to production!

### What Happens on PR Merge

When a PR is merged to `main`, GitHub Actions automatically:

1. ✅ Checks out the merged `main` branch
2. 📦 Backs up current production to `/home/andrew/web_server/backups/`
3. 📝 Writes deployment metadata (`version.json`)
4. 🚀 Deploys content to `/home/andrew/web_server/html/prod/`
5. 🔄 Restarts the `nginx-prod` container
6. ✓ Verifies the deployment succeeded

---

## 🏗️ Infrastructure

### Docker Services

Only two containers are now running:

| Container | Purpose | Port |
|-----------|---------|------|
| `nginx-proxy` | HTTPS reverse proxy (SSL termination) | 443 |
| `nginx-prod` | Production web server | proxied |

### Directory Structure

```
html/
  prod/              # Production content (deployed via GitHub Actions)
    index.html
    header.html
    footer.html
    version.json     # Auto-generated deployment metadata
    css/
    js/
    img/

includes/
  prod-env-banner.html  # Production environment banner

nginx/
  conf.d/
    prod.conf        # NGINX production configuration
    000-bareip.conf  # Bare IP redirect
```

---

## 🔧 Manual Operations

### Start/Stop Services

```bash
# Start production services
docker compose up -d

# Stop services
docker compose down

# Restart production
docker restart nginx-prod
```

### View Logs

```bash
# All services
docker compose logs -f

# Production only
docker logs -f nginx-prod

# Proxy only
docker logs -f nginx-proxy
```

### Manual Deployment (if needed)

```bash
# Deploy from local html/prod directory
rsync -av --delete html/prod/ /home/andrew/web_server/html/prod/
docker restart nginx-prod
```

---

## 🌐 Accessing the Site

**Production URL:** https://prod.mitchellnet.local

The site is accessible from any device on your local network.

---

## 📊 Deployment Metadata

Each deployment creates a `version.json` file with:

```json
{
  "env": "production",
  "commit": "abc123...",
  "deployed_at": "2025-12-21T10:30:00Z",
  "deployed_by": "username",
  "pr_number": "42",
  "pr_title": "Add new feature"
}
```

Access it at: https://prod.mitchellnet.local/version.json

---

## 🔐 Security

- All HTTP traffic is redirected to HTTPS
- Self-signed SSL certificates located in `/etc/ssl/certs/` and `/etc/ssl/private/`
- Containers run with read-only volumes for security

---

## 🔄 Rollback Procedure

If a deployment causes issues:

1. **Find the backup:**
   ```bash
   ls -la /home/andrew/web_server/backups/
   ```

2. **Restore from backup:**
   ```bash
   BACKUP_DIR="/home/andrew/web_server/backups/prod_backup_YYYYMMDD_HHMMSS"
   rsync -av --delete "$BACKUP_DIR/" /home/andrew/web_server/html/prod/
   docker restart nginx-prod
   ```

3. **Verify:**
   ```bash
   curl -sk https://prod.mitchellnet.local/version.json
   ```

---

## 📁 Files Removed in Simplification

The following are no longer needed and can be archived/deleted:

- `html/dev/` - Development directory
- `html/test/` - Test directory
- `includes/test-env-banner.html` - Test banner
- `nginx/conf.d/test.conf` - Test NGINX config
- `.github/workflows/deploy-test.yml` - Test deployment workflow
- `.github/workflows/promote-prod.yml` - Manual promotion workflow
- `docker-compose.dev.yml` - Development compose file (optional to keep)

See [CLEANUP.md](CLEANUP.md) for detailed cleanup instructions.

---

## 🆘 Troubleshooting

### Deployment Failed

Check GitHub Actions logs in the repository's "Actions" tab.

### Site Not Accessible

```bash
# Check container status
docker ps -a

# Check nginx configuration
docker exec nginx-proxy nginx -t

# Check logs
docker logs nginx-proxy
docker logs nginx-prod
```

### SSL Certificate Issues

```bash
# Verify certificates exist
ls -la /etc/ssl/certs/selfsigned.crt
ls -la /etc/ssl/private/selfsigned.key
```

---

## 📚 Additional Documentation

- Original documentation: [archive/README.md](archive/README.md)
- Developer notes: [archive/DeveloperNotes.md](archive/DeveloperNotes.md)
- Cleanup guide: [CLEANUP.md](CLEANUP.md)

---

## ✨ Benefits of Simplified Setup

✅ **Fewer branches** - No more develop/main confusion  
✅ **Automatic deployment** - No manual promotion steps  
✅ **Less complexity** - One environment to manage  
✅ **Faster workflow** - Merge PR = deployed  
✅ **Safer rollbacks** - Automatic backups on every deployment  

---

**Questions?** Check the troubleshooting section or review the GitHub Actions workflow at [.github/workflows/deploy-prod.yml](.github/workflows/deploy-prod.yml)
