.PHONY: help build up down logs shell clean test test-backup backup restore crontab

DOCKER := docker
COMPOSE := $(DOCKER) compose

help:
	@echo "Minimal Viable Docker Development Environment"
	@echo ""
	@echo "3 containers: nginx + php-fpm + postgresql"
	@echo ""
	@echo "Commands:"
	@echo "  make build          Build Docker images"
	@echo "  make up             Start all containers"
	@echo "  make down           Stop all containers"
	@echo "  make logs           View logs"
	@echo "  make shell          Shell into container (service=php|db|webserver)"
	@echo "  make clean          Remove containers and volumes"
	@echo "  make test           Run HTTP and DB tests"
	@echo "  make test-backup    Run backup script tests"
	@echo "  make backup         Backup database"
	@echo "  make restore        Restore database (file=<backup>)"
	@echo "  make crontab        Install crontab jobs"

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
	@case "$(service)" in \
		db) container="postgresql-container";; \
		php) container="php-fpm-container";; \
		webserver) container="nginx-container";; \
		*) echo "Invalid service: $(service)"; exit 1;; \
	esac
	$(DOCKER) exec -it $$container /bin/sh

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
	@$(DOCKER) exec mv-postgresql-container pg_isready -U docker -d dockerdb && echo "OK: db"
	@echo "All tests passed"

test-backup:
	@bash backup/test_backup.sh

backup:
	@bash backup/backup.sh

restore:
	@bash backup/restore.sh $(file)

crontab:
	@echo "Installing crontab..."
	@cat crontab.txt | crontab -
	@echo "Done. Crontab installed:"
	@crontab -l