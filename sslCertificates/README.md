# SSL Certificate for MitchellNet Internal Server

This directory contains certificate files used by the production server at 192.168.2.10.

## Current Certificate Setup (as of April 2026)

The server now uses an **mkcert**-generated certificate that is trusted by the Mac's system keychain. This replaced the old self-signed OpenSSL CA cert after Edge stopped trusting the self-signed cert following a browser update.

## Files

- `mitchellnet-ca.crt` - Legacy self-signed CA certificate (kept for reference / iOS use — see below)

## Important Notes

⚠️ **Private key files are NOT stored in this repository for security reasons.**

The active certificate and key live on the production server at:
- `/home/andrew/web_server/nginx/certs/server.crt`
- `/home/andrew/web_server/nginx/certs/server.key`

Both `prod.conf` and `000-bareip.conf` reference these paths.

## Current Certificate Details

- **Tool used:** `mkcert` (creates certs trusted by macOS Keychain automatically)
- **Valid for:**
  - DNS: mitchellnet.local
  - IP: 192.168.2.10
- **Expires:** July 2028
- **Trusted by:** macOS Keychain (Safari, Chrome, Edge on Mac)

## Renewing the Certificate (When It Expires or Edge Breaks Again)

### Step 1 — Generate new cert on your Mac

```bash
mkcert mitchellnet.local 192.168.2.10
```

This produces two files in your current directory:
- `mitchellnet.local+1.pem`
- `mitchellnet.local+1-key.pem`

### Step 2 — Copy cert files to the server

```bash
scp ~/mitchellnet.local+1.pem ~/mitchellnet.local+1-key.pem andrew@192.168.2.10:/home/andrew/web_server/nginx/certs/
```

### Step 3 — Rename files on the server

```bash
ssh andrew@192.168.2.10
cd /home/andrew/web_server/nginx/certs/
mv mitchellnet.local+1.pem server.crt
mv mitchellnet.local+1-key.pem server.key
```

### Step 4 — Restart nginx

```bash
cd /home/andrew/web_server && docker compose restart nginx-proxy
```

No nginx config changes needed — `prod.conf` and `000-bareip.conf` already reference `server.crt` / `server.key`.

## iOS Devices

iOS requires a certificate to have `CA:TRUE` and be installed as a profile. The mkcert cert is a leaf cert (not a CA), so iOS devices should still use the old `mitchellnet-ca.crt` workflow (AirDrop/email, install profile, enable in Certificate Trust Settings). See the main README.md section 9 for details.
