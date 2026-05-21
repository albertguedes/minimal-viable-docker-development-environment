.PHONY: help build up down logs shell clean test backup restore crontab

DOCKER := docker
COMPOSE := $(DOCKER) compose

help:
	@echo "Minimal Viable Docker Development Environment"
	@echo ""
	@echo "3 containers: nginx + php-fpm + postgresql"
	@echo ""
	@echo "Commands:"
	@echo "  make build    Build Docker images"
	@echo "  make up       Start all containers"
	@echo "  make down     Stop all containers"
	@echo "  make logs     View logs"
	@echo "  make shell    Shell into container (service=php|db|webserver)"
	@echo "  make clean    Remove containers and volumes"
	@echo "  make test     Run tests"
	@echo "  make backup   Backup database"
	@echo "  make restore  Restore database (file=<backup>)"
	@echo "  make crontab  Install crontab jobs"

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs

logs service=$(service):
	$(COMPOSE) logs $(service)

shell:
	@if [ -z "$(service)" ]; then \
		echo "Usage: make shell service=<db|php|webserver>"; \
		exit 1; \
	fi
	$(DOCKER) exec -it $(service)-container /bin/sh

clean:
	$(COMPOSE) down -v

status:
	$(COMPOSE) ps

test:
	@echo "Testing..."
	@curl -sf http://localhost:8080/ > /dev/null && echo "OK: /"
	@curl -sf http://localhost:8080/index.php > /dev/null && echo "OK: /index.php"
	@curl -sf http://localhost:8080/database.php > /dev/null && echo "OK: /database.php"
	@curl -sf http://localhost:8080/health > /dev/null && echo "OK: /health"
	@curl -sf http://localhost:8080/metrics.php > /dev/null && echo "OK: /metrics.php"
	@$(DOCKER) exec postgresql-container pg_isready -U $${POSTGRES_USER:-docker} -d $${POSTGRES_DB:-dockerdb} && echo "OK: db"
	@echo "All tests passed"

backup:
	@bash backup/backup.sh

restore:
	@bash backup/restore.sh $(file)

crontab:
	@echo "Installing crontab..."
	@cat crontab.txt | crontab -
	@echo "Done. Crontab installed:"
	@crontab -l