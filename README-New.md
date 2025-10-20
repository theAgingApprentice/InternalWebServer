# NGINX Reverse Proxy — Production & Test Subdomain Setup

> **Access URLs**
>
> - **Production site:** [`https://prod.mitchellnet.local`](https://prod.mitchellnet.local)
> - **Test site:** [`https://test.mitchellnet.local`](https://test.mitchellnet.local)
> - **Bare IP:** [`https://192.168.2.10`](https://192.168.2.10) → redirects to `prod.mitchellnet.local`
>
> To resolve these names locally, ensure your `/etc/hosts` file contains:
> ```
> 192.168.2.10 prod.mitchellnet.local test.mitchellnet.local
> ```

---

## Overview

This repository documents the working **NGINX reverse-proxy** and **multi-environment web server** stack deployed on the `MitchellNET` internal network (`192.168.2.10`).  
The proxy container fronts two backend NGINX servers (`nginx-prod` and `nginx-test`), each serving their own content directories and environment banners.

The setup runs on **Ubuntu Server 24.04.2 LTS** hosted on a **2019 iMac (model iMac19,1)** and uses Docker Compose for orchestration.

---

## 🧩 Architecture Summary

| Component | Purpose | Host Path | Container Mount |
|------------|----------|------------|----------------|
| **nginx-proxy** | Reverse proxy for subdomains | `./nginx/conf.d` | `/etc/nginx/conf.d` |
| **nginx-prod** | Production web root | `./html/prod` | `/usr/share/nginx/html` |
| **nginx-test** | Test web root | `./html/test` | `/usr/share/nginx/html` |
| **Self-signed SSL** | TLS cert for internal HTTPS | `/etc/ssl/certs/selfsigned.crt` | `/etc/nginx/ssl/selfsigned.crt` |
| | | `/etc/ssl/private/selfsigned.key` | `/etc/nginx/ssl/selfsigned.key` |

### Behavior
- **Bare IP (`192.168.2.10`)** → Redirects `/` to `prod.mitchellnet.local`, returns `404` for `/prod` and `/test`.
- **Subdomains:**
  - `prod.mitchellnet.local` → `nginx-prod` container (adds header `X-Upstream: prod`)
  - `test.mitchellnet.local` → `nginx-test` container (adds header `X-Upstream: test`)

---

## 🧱 Directory Structure

```
/home/andrew/web_server/
├── docker-compose.yml
├── Makefile
├── includes/
│   ├── prod-env-banner.html
│   └── test-env-banner.html
├── html/
│   ├── prod/
│   └── test/
└── nginx/
    ├── conf.d/
    │   ├── 000-bareip.conf
    │   ├── prod.conf
    │   ├── test.conf
    │   └── proxy.conf.off
    └── _snap_YYYY-MM-DD_HHMMSS/    # Auto snapshots
```

---

## ⚙️ Daily Operations

| Command | Description |
|----------|--------------|
| `make check` | Tests redirects and subdomain routing |
| `make reload` | Reloads nginx-proxy configuration |
| `make logs` | Shows last 80 lines of nginx-proxy logs |
| `make snapshot` | Saves current configs under `nginx/_snap_` |
| `make restart-proxy` | Recreates nginx-proxy only |
| `make restart-backends` | Recreates both prod/test backend containers |

---

## 🧭 Backup & Version Control

### 1️⃣ Copy this setup to your **development machine**

On the **production host (`192.168.2.10`)**:
```bash
cd /home/andrew
tar -czvf web_server_backup_20251018.tar.gz web_server
scp web_server_backup_20251018.tar.gz andrew@dev-machine:/home/andrew/
```

On the **development machine**:
```bash
cd /home/andrew
tar -xzvf web_server_backup_20251018.tar.gz
cd web_server
docker compose up -d
```

This allows testing or editing configs without overwriting production files.

---

### 2️⃣ Back up configuration to **GitHub**

From `/home/andrew/web_server`:
```bash
make snapshot
cd nginx/_snap_YYYY-MM-DD_HHMMSS
tar -czvf nginx_config_backup.tar.gz conf.d docker-compose.yml
mv nginx_config_backup.tar.gz ../../
cd ../..
git add nginx_config_backup.tar.gz
git commit -m "Backup: nginx configuration snapshot 2025-10-18"
git push origin main
```

To **restore** later:
```bash
tar -xzvf nginx_config_backup.tar.gz -C nginx/
docker compose up -d --force-recreate --no-deps nginx-proxy
```

---

## 🔒 Notes

- Only internal use (`.local`) — not exposed externally.  
- SSL is self-signed; browsers will show a warning (acceptable for local/internal).  
- No dynamic proxy scripts or autoconf; everything is manual and snapshot-controlled.

---

**Author:** Andrew Mitchell — *TheAgingApprentice*  
**System:** Ubuntu Server 24.04.2 LTS (iMac19,1)  
**Project:** `MitchellNET` Internal Web Server  
**Last Updated:** 2025-10-18 23:41:21
