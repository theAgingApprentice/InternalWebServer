# NGINX Location Block Map

This document describes every URL path prefix handled by the `nginx-proxy` container, where each path proxies to, any special settings, and the reason for those settings.

The active configuration lives in [nginx/conf.d/prod.conf](../nginx/conf.d/prod.conf) (domain-name virtual host) and [nginx/conf.d/000-bareip.conf](../nginx/conf.d/000-bareip.conf) (bare-IP virtual host).

---

## prod.conf — `mitchellnet.local` virtual host

### `location /api/bench/`

```nginx
location /api/bench/ {
    proxy_pass http://bench-instrument-service:8000/;
    proxy_http_version 1.1;
    proxy_read_timeout 120s;
    proxy_send_timeout 120s;
    add_header X-Upstream bench-instrument-service;
}
```

| Setting | Value | Reason |
|---------|-------|--------|
| **Upstream** | `bench-instrument-service:8000` | Bench Instrument Service container, resolved by Docker DNS via the `mitchellnet` external network |
| `proxy_read_timeout 120s` | 120 seconds | BIS operations (waveform capture, multimeter logging) can take many seconds; the default 60 s timeout caused premature disconnects |
| `proxy_send_timeout 120s` | 120 seconds | Paired with read timeout to keep the upstream connection alive for slow POST payloads from the client |
| `proxy_http_version 1.1` | HTTP/1.1 | Enables keep-alive connections to the upstream |

> **Why 120 s?** Waveform captures and continuous multimeter logging sessions hold the connection open while data streams from bench hardware. The default 60 s read timeout was insufficient and caused clients to receive a 504 Gateway Timeout mid-capture.

---

### `location /api/`

```nginx
location /api/ {
    proxy_pass http://fitness-tracker-backend-prod:5000/api/;
    proxy_http_version 1.1;
    add_header X-Upstream fitness-tracker-backend;
}
```

| Setting | Value | Reason |
|---------|-------|--------|
| **Upstream** | `fitness-tracker-backend-prod:5000` | Fitness Tracker Flask backend container on the internal `webnet` network |
| Default timeouts | 60 s (NGINX default) | REST API calls complete quickly; no extended timeout needed |
| `proxy_http_version 1.1` | HTTP/1.1 | Enables keep-alive connections to the upstream |

> **Ordering note:** `/api/bench/` is declared before `/api/` so NGINX's longest-prefix matching routes BIS requests correctly before the general `/api/` block can match them.

---

### `location /`

```nginx
location / {
    ssi on;
    proxy_set_header Accept-Encoding "";
    proxy_pass http://nginx-prod;
    add_header X-Upstream production;
}
```

| Setting | Value | Reason |
|---------|-------|--------|
| **Upstream** | `nginx-prod` (port 80) | Static content container serving HTML/CSS/JS from `html/prod/` |
| `ssi on` | enabled | Server-Side Includes are used to inject shared header/footer fragments into pages |
| `Accept-Encoding ""` | disabled | Prevents upstream gzip compression so NGINX's SSI parser can read and process the HTML before sending it to the client |

---

### `location /includes/`

```nginx
location /includes/ {
    alias /home/andrew/web_server/includes/;
    autoindex off;
    add_header Cache-Control "no-store";
}
```

| Setting | Value | Reason |
|---------|-------|--------|
| **Served from** | Host filesystem (`./includes/` volume-mounted into the proxy container) | SSI fragments (shared header, footer, nav) are stored here and served directly by the proxy rather than a backend |
| `autoindex off` | disabled | Directory listing hidden for security |
| `Cache-Control: no-store` | no caching | Ensures browsers and proxies always fetch the latest fragment version |

---

## 000-bareip.conf — `192.168.2.10` virtual host

The bare-IP virtual host mirrors most of `prod.conf` but without the `/api/bench/` BIS route (BIS is only accessible via the domain name). The location blocks it does include behave identically:

| Location | Upstream | Notes |
|----------|----------|-------|
| `/api/` | `fitness-tracker-backend-prod:5000` | Same as prod.conf |
| `/` | `nginx-prod` | SSI on, Accept-Encoding cleared |
| `/includes/` | Host filesystem alias | Same as prod.conf |

---

## Common Proxy Headers

Both virtual hosts set these headers for all proxied locations:

```nginx
proxy_set_header Host              $host;
proxy_set_header X-Real-IP         $remote_addr;
proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```

These are declared at the `server {}` block level so every `location {}` inherits them.

---

## Network Dependencies

`bench-instrument-service` is resolved by Docker DNS. The `nginx-proxy` container must be on the `mitchellnet` external Docker network for this name to resolve — see [README.md § 12 Network](../README.md#12-network).

`fitness-tracker-backend-prod` and `nginx-prod` are resolved on the `webnet` internal network defined in `docker-compose.yml`.

---

*Last updated: 2026-06-04*
