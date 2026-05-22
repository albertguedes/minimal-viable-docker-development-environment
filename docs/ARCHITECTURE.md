# Architecture

Technical documentation for the Minimal Viable Docker Development Environment (v0.10.1).

---

## Overview

Three services run on the host network: **nginx** (HTTP), **PHP-FPM** (application runtime), and **PostgreSQL** (data). Nginx serves static files and forwards `*.php` requests to PHP-FPM via FastCGI on `127.0.0.1:9000`. PHP connects to PostgreSQL on `127.0.0.1:5432`.

Only **Docker** and **Make** are required on the host; Composer and PHPUnit run inside the PHP image.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         HOST MACHINE                            │
│                                                                 │
│   127.0.0.1:8080  ── nginx (mv-nginx-container)                 │
│                         │ fastcgi_pass 127.0.0.1:9000           │
│                         ▼                                       │
│   127.0.0.1:9000  ── PHP-FPM (mv-php-fpm-container)            │
│                         │ pg_connect 127.0.0.1:5432             │
│                         ▼                                       │
│   127.0.0.1:5432  ── PostgreSQL (mv-postgresql-container)       │
│                                                                 │
│   ./src ──────────────────────▶ /var/www/html (php + nginx)   │
│   ./database/data ────────────▶ /var/lib/postgresql/data        │
└─────────────────────────────────────────────────────────────────┘
```

All services use **`network_mode: host`**. Compose `ports:` mappings are not used (Docker ignores them in host mode). Services bind directly on the host loopback.

---

## Services

### 1. Web Server (nginx)

| Property | Value |
|----------|-------|
| Image | nginx:1.27-alpine |
| Container | mv-nginx-container |
| Listen | `127.0.0.1:8080` (configured in `webserver/nginx/default.conf`) |
| Config | `webserver/nginx/default.conf`, `nginx.conf` |
| Dockerfile | `webserver/Dockerfile` |

**Responsibilities:**

- Serve static files from `/var/www/html` (volume: `./src`, read-only)
- Proxy PHP to `127.0.0.1:9000` via FastCGI
- Inline `/health` response (no PHP)

**Request flow:**

```
Client → :8080 → location ~ \.php$ → fastcgi_pass 127.0.0.1:9000 → PHP-FPM
```

### 2. PHP Processor (php-fpm)

| Property | Value |
|----------|-------|
| Image | php:8.4-fpm-alpine (8.2/8.3 via build arg) |
| Container | mv-php-fpm-container |
| Listen | `127.0.0.1:9000` (FastCGI) |
| Dockerfile | `php/Dockerfile` (build context: repository root) |
| User | www-data |
| Extensions | pdo, pdo_pgsql, pgsql |
| Tools | Composer, PHPUnit 11 (phar) |

**Volumes:**

- `./src` → `/var/www/html`
- `./php/phpunit.xml.dist` → `/var/www/phpunit.xml.dist` (ro)
- `./php/tests` → `/var/www/tests` (ro)

**Environment (compose + `.env`):**

| Variable | Default in compose | Description |
|----------|-------------------|-------------|
| POSTGRES_HOST | `127.0.0.1` | Database host |
| POSTGRES_PORT | `5432` | Database port |
| POSTGRES_DB | from `.env` | Database name |
| POSTGRES_USER | from `.env` | Database user |
| POSTGRES_PASSWORD | from `.env` | Database password |

### 3. Database (PostgreSQL)

| Property | Value |
|----------|-------|
| Image | postgres:17-alpine |
| Container | mv-postgresql-container |
| Listen | `127.0.0.1:5432` |
| Dockerfile | `database/Dockerfile` |
| Data | `./database/data` → `/var/lib/postgresql/data` |

**Defaults:** database `dockerdb`, user `docker`, password from `.env`.

---

## Network Architecture

### Host networking

```yaml
network_mode: host
```

Inter-service traffic uses **loopback**:

| From | To | Address |
|------|-----|---------|
| Browser | nginx | `http://127.0.0.1:8080` |
| nginx | PHP-FPM | `127.0.0.1:9000` |
| PHP | PostgreSQL | `127.0.0.1:5432` |
| Host tools | PostgreSQL | `pg_isready -h 127.0.0.1 -p 5432` |

`depends_on` orders container start but does **not** wait for PostgreSQL readiness; use `make test` or `pg_isready` manually.

---

## Data Flow

### Static content

```
Browser → http://127.0.0.1:8080/index.html
       → nginx → /var/www/html/index.html
```

### PHP

```
Browser → http://127.0.0.1:8080/index.php
       → nginx → FastCGI 127.0.0.1:9000
       → PHP-FPM executes /var/www/html/index.php
```

### Database (via PHP)

```
Browser → http://127.0.0.1:8080/database.php
       → PHP pg_connect(host=127.0.0.1 port=5432 ...)
       → PostgreSQL
```

---

## Operational Checks

| Check | Command |
|-------|---------|
| HTTP | `curl -sf http://127.0.0.1:8080/health` |
| DB ready | `pg_isready -h 127.0.0.1 -p 5432 -U docker -d dockerdb` |
| Full suite | `make test` |

---

## Security Architecture

- Credentials in `.env` (gitignored), passed via `env_file`
- Services listen on host loopback (not exposed on all interfaces by default)
- PHP image runs as `www-data`
- nginx mounts `src` read-only
- CI: Hadolint on Dockerfiles, Trivy filesystem scan

**Production hardening (not included):** TLS termination, Docker Secrets, compose healthchecks, non-host networking.

---

## Build Context

| Service | Context | Dockerfile |
|---------|---------|------------|
| database | `./database/` | `Dockerfile` |
| php | `.` (repo root) | `php/Dockerfile` |
| webserver | `./webserver/` | `Dockerfile` |

The PHP image must build from the repository root because the Dockerfile copies `src/` and `php/tests/`.

---

## CI/CD

| Workflow | Trigger | Notes |
|----------|---------|-------|
| `ci.yml` | push/PR to `master` | PHP 8.2–8.4 matrix, compose test, Hadolint, Trivy, GHCR build |
| `cd.yml` | tag `v*` | Release images to GHCR; PHP build uses same context as CI |

---

## Future Considerations

- Bridge network + explicit port publishing for multi-project hosts
- Compose healthchecks with `depends_on: condition: service_healthy`
- TLS reverse proxy, Redis sessions, read replicas
