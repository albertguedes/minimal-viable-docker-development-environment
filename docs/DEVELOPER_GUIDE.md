# Developer Guide

Technical documentation for developers working on this project.

---

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+ (`docker compose` not `docker-compose`)
- GNU Make 3.81+
- Bash 4.0+

---

## Project Structure

```
.
├── src/                          # Application source (host -> container mount)
│   ├── index.html                # Static HTML served by nginx
│   ├── index.php                # PHP info page
│   └── database.php             # PostgreSQL connection test
├── database/                  # Database service
│   └── postgresql.dockerfile    # PostgreSQL 15 Alpine image
├── php/                         # PHP-FPM service
│   └── php.dockerfile           # PHP 8.2 FPM Alpine + PostgreSQL extensions
├── webserver/                   # Nginx service
│   ├── nginx.dockerfile         # Nginx 1.25 Alpine + curl
│   └── nginx/
│       └── default.conf         # Nginx FastCGI configuration
├── tests/                       # Test scripts
│   ├── validate-compose.sh       # compose.yaml validation
│   ├── test-healthchecks.sh     # Service health verification
│   ├── test-http-endpoints.sh   # HTTP endpoint tests
│   └── test-db-connection.sh   # Database connectivity tests
├── docs/                        # Documentation
├── compose.yaml           # Service orchestration
├── Makefile                     # Developer commands
├── .env                         # Environment variables (gitignored)
├── .env.example                 # Environment template
├── .gitignore                   # Git ignore patterns
├── AGENTS.md                    # Agent instructions
├── CHANGELOG.md                 # Version history
├── TODO.md                      # Planned improvements
└── VERSION                      # Version file
```

---

## Architecture

```
                    ┌─────────────────────────────────────────┐
                    │            HOST MACHINE                   │
                    │   127.0.0.1:8080 (nginx)                  │
                    │   127.0.0.1:9090 (php-fpm debug)         │
                    │   127.0.0.1:2345 (postgresql direct)     │
                    └──────────────────────┬──────────────────┘
                                           │
                    ┌──────────────────────┴──────────────────┐
                    │         Docker Network (app-network)      │
                    │                                              │
    ┌───────────────┴───────────────┐                          │
    │                               │                          │
┌───▼────────┐               ┌──────▼───────┐          ┌──────▼──────┐
│   nginx    │               │  php-fpm     │          │ postgresql  │
│  :80       │─────────────▶│  :9000       │─────────▶│   :5432     │
│            │   FastCGI     │              │  pg_connect  │            │
│ /usr/share │               │ /var/www/html│          │ /var/lib/   │
│   nginx/   │               │   (volume)   │          │ postgresql/ │
│   html     │               │              │          │ data        │
└────────────┘               └─────────────┘          │ (volume)    │
                                                       └─────────────┘
```

---

## Service Details

### nginx (webserver)

- **Image**: `nginx:1.27-alpine`
- **Config**: `webserver/nginx/default.conf`
- **Healthcheck**: `curl -f http://localhost:80`
- **Responsibilities**: Serve static files, proxy PHP to php-fpm via FastCGI

### php-fpm

- **Image**: `php:8.4-fpm-alpine`
- **Extensions**: `pgsql`, `pdo`, `pdo_pgsql`
- **Healthcheck**: `pg_isready -h postgresql-container`
- **Environment**: Reads DB credentials from `.env`
- **Volume**: `./src` mounted to `/var/www/html`

### postgresql

- **Image**: `postgres:17-alpine`
- **Healthcheck**: `pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}`
- **Credentials**: From `.env` via `env_file`
- **Volume Mount**: `./database/data` → `/var/lib/postgresql/data`

---

## Debugging

### Shell Access

```bash
# PHP container
make shell service=php

# PostgreSQL container
make shell service=db

# Nginx container
make shell service=webserver
```

### View Logs

```bash
# All services
make logs

# Specific service
make logs service=db
make logs service=php
make logs service=webserver
```

### Check Container Status

```bash
make status
# or
docker compose ps
```

### Test Database Connection

```bash
# From host
psql -h localhost -p 2345 -U docker -d dockerdb

# From PHP container
docker exec php-fpm-container pg_isready -h postgresql-container -U docker

# Full HTTP test
curl http://localhost:8080/database.php
```

---

## Adding New PHP Extensions

Edit `php/php.dockerfile`:

```dockerfile
FROM php:8.4-fpm-alpine

RUN apk add --no-cache libpq-dev postgresql-client \
    && docker-php-ext-install pgsql pdo pdo_pgsql
# Add more extensions here
```

Then rebuild:
```bash
make build && make down && make up
```

---

## Adding New Pages

Place PHP/HTML files in `src/` directory. They are automatically mounted to `/var/www/html` in the php-fpm container.

```
src/
├── index.html     # Static HTML
├── index.php      # PHP info
├── database.php   # DB test
└── your-file.php  # New file
```

Access at `http://localhost:8080/your-file.php`

---

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `POSTGRES_DB` | Yes | dockerdb | Database name |
| `POSTGRES_USER` | Yes | docker | Database user |
| `POSTGRES_PASSWORD` | Yes | - | Database password |

Variables are loaded via `env_file: .env` in compose.yaml.

---

## Testing

```bash
# Run all tests
make test

# Individual tests
make test-validate   # compose.yaml validation
make test-health     # Wait for services healthy
make test-http       # HTTP endpoint tests
make test-db         # Database connectivity
```

---

## Common Tasks

### Rebuild After Dockerfile Changes

```bash
make build
```

### Clean Start

```bash
make clean     # Remove containers and volumes
make build     # Rebuild images
make up        # Start fresh
```

### Reset Database

```bash
make down
docker volume rm minimal_viable_postgres-data  # No longer needed with bind mount
make up
```

---

## Troubleshooting

### Container Unhealthy

```bash
# Check health status
docker compose ps

# View logs for specific service
make logs service=php

# Rebuild specific service
docker compose build php && docker compose up -d php
```

### Port Conflicts

```bash
# Check what's using port 8080
lsof -i :8080
# or
netstat -tulpn | grep 8080
```

### Database Connection Fails

1. Wait for db healthcheck (30s startup)
2. Verify .env exists and has correct values
3. Check pg_isready from PHP container:
   ```bash
   docker exec php-fpm-container pg_isready -h postgresql-container -U docker
   ```

---

## Version Information

| Component | Version |
|-----------|---------|
| nginx | 1.27-alpine |
| PHP | 8.4-fpm-alpine |
| PostgreSQL | 17-alpine |
| Docker Compose | 3.8 |

See [VERSION](./VERSION) file for project version.