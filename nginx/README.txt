NGINX proxy layout (Docker):
- prod.conf   -> vhost for prod.mitchellnet.local (proxied to container "nginx-prod")
- test.conf   -> vhost for test.mitchellnet.local (proxied to container "nginx-test")
- 000-bareip.conf -> bare-IP server: "/" redirects to prod.mitchellnet.local; all other paths 404
- default.conf -> bind-mounted from /home/andrew/web_server/proxy.conf (stubbed: "disabled by 000-bareip.conf")

Includes/banners:
- Served by proxy via /includes/ alias, files live inside container at /home/andrew/web_server/includes
- We copied the current fragments prod-env-banner.html & test-env-banner.html there.

Notes:
- Backends mount:
  - nginx-prod -> /home/andrew/web_server/html/prod -> /usr/share/nginx/html
  - nginx-test -> /home/andrew/web_server/html/test -> /usr/share/nginx/html
- HTML uses relative asset paths (e.g. css/style.css), so /prod and /test prefixes don’t break assets.
- Proxy sets "Accept-Encoding" "" for HTML paths so SSI can work when needed.

How to update:
1) Edit /home/andrew/web_server/html/{prod|test}/... as usual.
2) If you change proxy vhosts, update /etc/nginx/conf.d/*.conf in the container (or keep copies in /home/andrew/web_server and docker cp them in).
3) Test then reload: docker exec -it nginx-proxy nginx -t && docker exec -it nginx-proxy nginx -s reload
