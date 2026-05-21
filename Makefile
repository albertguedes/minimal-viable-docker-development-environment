.PHONY: help build up down logs shell clean status ps test test-validate test-health test-http test-db

DOCKER := docker
COMPOSE := $(DOCKER) compose

help:
	@echo "Minimal Viable Docker Development Environment"
	@echo ""
	@echo "Usage:"
	@echo "  make build              Build Docker images"
	@echo "  make up                 Start all containers"
	@echo "  make down               Stop all containers"
	@echo "  make logs               View all logs"
	@echo "  make logs service=<s>   View service logs (db|php|webserver)"
	@echo "  make shell service=<s>  Shell into container (db|php|webserver)"
	@echo "  make status             Show container status"
	@echo "  make ps                 List running containers"
	@echo "  make clean              Remove containers and volumes"
	@echo "  make test               Run all tests"
	@echo "  make test-validate      Validate docker-compose config"
	@echo "  make test-health        Wait for services to be healthy"
	@echo "  make test-http          Test HTTP endpoints"
	@echo "  make test-db            Test database connectivity"
	@echo ""

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

test: test-validate test-health test-http test-db
	@echo "All tests passed"

test-validate:
	@bash tests/validate-compose.sh

test-health:
	@bash tests/test-healthchecks.sh

test-http:
	@bash tests/test-http-endpoints.sh

test-db:
	@bash tests/test-db-connection.sh