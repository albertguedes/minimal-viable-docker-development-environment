# minimal-viable-docker-development-environment

## Stack
- nginx:1.27-alpine → port 8080
- php:8.4-fpm-alpine → port 9090 (internal)
- postgres:17-alpine → port 2345 (internal)

## Commands
- `make up` - start all containers
- `make down` - stop all containers
- `make build` - rebuild images after Dockerfile changes
- `make logs [service=]` - view logs (all or specific service)
- `make shell service=<db|php|webserver>` - exec into container
- `make clean` - remove containers and volumes
- `make test` - run all tests

## Setup
1. `cp .env.example .env`
2. Edit `.env` with your credentials
3. `make build && make up`

## URLs
- http://localhost:8080/ - nginx welcome page
- http://localhost:8080/index.php - phpinfo()
- http://localhost:8080/database.php - postgres connection test

## Database
- Host: postgresql-container
- Port: 5432
- Credentials from .env (POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD)

## Structure
- `src/` - source code (mounted to php-fpm at /var/www/html)
- `db/postgresql.dockerfile` - postgres image
- `php/php.dockerfile` - php-fpm image (pdo_pgsql installed)
- `webserver/nginx.dockerfile` - nginx image
- `webserver/nginx/default.conf` - nginx config
- `docs/` - developer guide and user manual

## Notes
- Uses `docker compose` (v2 plugin), not `docker-compose` (v1)
- Ports bind to 127.0.0.1 (localhost only)
- Services wait for db healthcheck before starting
- Data persists in named docker volume `minimal_viable_postgres-data`
- PHP container has `postgresql-client` for healthchecks
- nginx has `curl` for healthchecks