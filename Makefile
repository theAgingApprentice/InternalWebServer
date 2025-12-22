COMPOSE_FILE = docker-compose.dev.yml

.PHONY: up down reload logs certs nuke

up:
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

reload:
	docker exec nginx-proxy-dev nginx -s reload || true

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

certs:
	@echo "Generating dev certs for prod.mitchellnet.local and test.mitchellnet.local ..."
	mkdir -p ssl
	@if ! command -v mkcert >/dev/null 2>&1; then \
		echo "Installing mkcert (requires Homebrew)..." && brew install mkcert nss || true; \
	fi
	mkcert -install
	mkcert -key-file ssl/dev.key -cert-file ssl/dev.crt "mitchellnet.dev.local" "localhost"
	@echo "Certs written to ./ssl/dev.crt and ./ssl/dev.key"

nuke:
	-docker compose -f $(COMPOSE_FILE) down -v --remove-orphans
	-docker rm -f nginx-proxy-dev nginx-prod-dev nginx-test-dev
