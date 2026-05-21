.PHONY: help build up down logs shell clean status ps test

DOCKER := docker
COMPOSE := $(DOCKER) compose

help:
	@echo "Minimal Viable Docker Development Environment"
	@echo ""
	@echo "Usage:"
	@echo "  make build     Build Docker images"
	@echo "  make up        Start all containers"
	@echo "  make down      Stop all containers"
	@echo "  make logs      View all logs"
	@echo "  make shell     Shell into container (service=php|db|webserver)"
	@echo "  make clean     Remove containers and volumes"
	@echo "  make status    Show container status"
	@echo "  make test      Test HTTP and database"

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

status:
	$(COMPOSE) ps

ps:
	$(COMPOSE) ps

clean:
	$(COMPOSE) down -v --remove-orphans

test:
	@echo "Testing HTTP endpoints..."
	@curl -sf http://localhost:8080/ > /dev/null && echo "OK: / returns 200"
	@curl -sf http://localhost:8080/index.php > /dev/null && echo "OK: /index.php returns 200"
	@curl -sf http://localhost:8080/database.php > /dev/null && echo "OK: /database.php returns 200"
	@echo "Testing database..."
	@$(DOCKER) exec postgresql-container pg_isready -U $${POSTGRES_USER:-docker} -d $${POSTGRES_DB:-dockerdb} && echo "OK: database ready"
	@echo "All tests passed"