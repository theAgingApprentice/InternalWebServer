# Dev Reverse Proxy Setup (Parallels Production)

This bundle gives you a drop-in development setup that mirrors production:

- TLS-terminating **nginx-proxy** routing by host:
  - `prod.mitchellnet.local` → `nginx-prod-dev` (serves `./html/prod`)
  - `test.mitchellnet.local` → `nginx-test-dev` (serves `./html/test`)
- Backends are plain `nginx:latest` containers serving static files
- Works with your repo layout: `html/prod` and `html/test`

## 1) Hosts entries (on your dev machine)

Edit `/etc/hosts` and add:

```
127.0.0.1   prod.mitchellnet.local
127.0.0.1   test.mitchellnet.local
```

## 2) Generate trusted dev certs

From the repo root (where this bundle lives):

```
make certs
```

This uses [mkcert](https://github.com/FiloSottile/mkcert) to create `./ssl/dev.crt` and `./ssl/dev.key`.

## 3) Start the stack

```
make up
```

Now open:

- https://prod.mitchellnet.local
- https://test.mitchellnet.local

## 4) Live editing

Edit files under `html/prod` or `html/test` and refresh the browser. No container reload is required for HTML/CSS/JS.

If you edit `proxy/default.conf`, run:

```
make reload
```

## Notes

- Use **root‑relative** URLs in your HTML and partials: `/css/style.css`, `/img/...`, `/tools/`, etc.
- Ensure your client-side include script pulls `/header.html` and `/footer.html` from each site root.
- The compose file name is `docker-compose.dev.yml` so it won't collide with your prod compose.
