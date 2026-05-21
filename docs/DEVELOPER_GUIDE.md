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
├── src/                          # Application source
│   ├── index.html                # Static HTML served by nginx
│   ├── index.php                # PHP info page
│   └── database.php             # PostgreSQL connection test
├── database/                     # Database service
│   └── postgresql.dockerfile    # PostgreSQL 17 Alpine image
├── php/                          # PHP-FPM service
│   └── php.dockerfile           # PHP 8.4 FPM Alpine + PostgreSQL extensions
├── webserver/                    # Nginx service
│   ├── nginx.dockerfile         # Nginx 1.27 Alpine + curl
│   └── nginx/
│       └── default.conf         # Nginx FastCGI configuration
├── docs/                         # Documentation
├── compose.yaml                  # Service orchestration
├── Makefile                      # Developer commands
├── .env                          # Environment variables (gitignored)
├── .env.example                  # Environment template
├── .gitignore                    # Git ignore patterns
├── LICENSE                       # MIT License
├── README.md                     # Project overview
├── CHANGELOG.md                  # Version history
├── TODO.md                       # Planned improvements
└── VERSION                       # Version file
```

---

## Stack

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| nginx | nginx:1.27-alpine | 8080 | HTTP server, FastCGI proxy |
| php-fpm | php:8.4-fpm-alpine | 9000 (internal) | PHP processor |
| postgresql | postgres:17-alpine | 2345 | Database |

---

## Quick Start

```bash
cp .env.example .env
make build && make up
```

Access:
- http://localhost:8080/ - nginx welcome page
- http://localhost:8080/index.php - PHP info
- http://localhost:8080/database.php - Database connection test

---

## Commands

```bash
make up       # Start all services
make down     # Stop all services
make build    # Rebuild images after Dockerfile changes
make logs     # View logs (all or specific: make logs service=php)
make shell    # Shell access (make shell service=php|db|webserver)
make clean    # Remove containers and volumes
make test     # Run all tests
```

---

## Service Details

### nginx

- **Image**: `nginx:1.27-alpine`
- **Config**: `webserver/nginx/default.conf`
- **Healthcheck**: `curl -f http://localhost:80`
- **Responsibilities**: Serve static files, proxy PHP to php-fpm via FastCGI

### php-fpm

- **Image**: `php:8.4-fpm-alpine`
- **Extensions**: `pgsql`, `pdo`, `pdo_pgsql`
- **Volume**: `./src` mounted to `/var/www/html`

### postgresql

- **Image**: `postgres:17-alpine`
- **Volume**: `./database/data` mounted to `/var/lib/postgresql/data`

---

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `POSTGRES_DB` | Yes | dockerdb | Database name |
| `POSTGRES_USER` | Yes | docker | Database user |
| `POSTGRES_PASSWORD` | Yes | - | Database password |

---

## Troubleshooting

### Container Won't Start

```bash
docker compose ps
docker compose logs db
```

### Port Conflicts

```bash
lsof -i :8080
```

### Database Connection Fails

1. Wait 30s for database initialization
2. Verify `.env` has correct credentials
3. Check: `docker exec php-fpm-container pg_isready -h postgresql-container -U docker`

---

## Optional Stacks

Run with: `docker compose -f compose.yaml -f compose.<stack>.yml up -d`

### backup - Database Backup/Restore

```bash
docker compose -f compose.yaml -f compose.backup.yml up -d backup
make backup                    # Create backup
make restore file=<file>       # Restore from backup
```

### monitoring - Prometheus + Grafana

```bash
docker compose -f compose.yaml -f compose.monitoring.yml up -d
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)
```

### security - Fail2ban + Uptime Kuma

```bash
docker compose -f compose.yaml -f compose.security.yml up -d
# Uptime Kuma: http://localhost:3001
```

### perf - PHP opcache + nginx cache

```bash
docker compose -f compose.yaml -f compose.perf.yml up -d
```
