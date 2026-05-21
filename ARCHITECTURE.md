# Architecture

Detailed technical documentation of the Minimal Viable Docker Development Environment.

---

## Overview

This project provides a containerized development environment consisting of three services: an HTTP server (nginx), a PHP processor (php-fpm), and a database (PostgreSQL). The architecture follows the standard web application pattern where nginx acts as a reverse proxy, forwarding PHP requests to the PHP-FPM processor via FastCGI.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         HOST MACHINE                            │
│                      (macOS / Linux / Windows)                 │
│                                                                 │
│   127.0.0.1:8080 ─────── nginx webserver                       │
│   127.0.0.1:9090 ─────── php-fpm (debug port)                  │
│   127.0.0.1:2345 ─────── postgresql (direct access)            │
│                                                                 │
│   ┌────────────────────────────────────────────────────────┐   │
│   │              Docker Network (app-network)              │   │
│   │                                                          │   │
│   │   ┌──────────────┐    ┌──────────────┐    ┌─────────┐ │   │
│   │   │    nginx     │───▶│  php-fpm      │───▶│postgres │ │   │
│   │   │  container   │    │  container    │    │ container│ │   │
│   │   └──────────────┘    └──────────────┘    └─────────┘ │   │
│   │                                                          │   │
│   └────────────────────────────────────────────────────────┘   │
│                                                                 │
│   ./src ──────────────────────────▶ /var/www/html (volume)    │
│   ./database/data (bind mount) ────▶ /var/lib/postgresql/data │
└─────────────────────────────────────────────────────────────────┘
```

---

## Services

### 1. Web Server (nginx)

| Property | Value |
|----------|-------|
| Image | nginx:1.27-alpine |
| Container | nginx-container |
| Host Port | 8080 |
| Container Port | 80 |
| Configuration | webserver/nginx/default.conf |
| Health Check | HTTP GET / |

**Responsibilities:**
- Serve static files (HTML, CSS, JavaScript)
- Proxy PHP requests to php-fpm container via FastCGI
- Load balancing (future: multiple php-fpm instances)
- SSL/TLS termination (future)

**Request Flow:**
```
Client → nginx:80 → location ~ \.php$ → fastcgi_pass php-fpm:9000
                                          ↓
                              PHP processor → returns result
```

### 2. PHP Processor (php-fpm)

| Property | Value |
|----------|-------|
| Image | php:8.4-fpm-alpine |
| Container | php-fpm-container |
| Host Port | 9090 |
| Container Port | 9000 |
| Volume Mount | ./src → /var/www/html |
| Extensions | pgsql, pdo, pdo_pgsql |

**Responsibilities:**
- Parse and execute PHP code
- Connect to PostgreSQL database
- Session management
- File operations in /var/www/html

**Environment Variables:**
| Variable | Source | Description |
|----------|--------|-------------|
| POSTGRES_HOST | .env | Database hostname |
| POSTGRES_PORT | .env | Database port |
| POSTGRES_DB | .env | Database name |
| POSTGRES_USER | .env | Database user |
| POSTGRES_PASSWORD | .env | Database password |

### 3. Database (PostgreSQL)

| Property | Value |
|----------|-------|
| Image | postgres:17-alpine |
| Container | postgresql-container |
| Host Port | 2345 |
| Container Port | 5432 |
| Volume Mount | `./database/data` → `/var/lib/postgresql/data` |
| Health Check | pg_isready |

**Responsibilities:**
- Store application data
- User authentication
- Data persistence across container restarts
- SQL query processing

**Default Configuration:**
- Database: dockerdb
- User: docker
- Password: (from POSTGRES_PASSWORD in .env)

---

## Network Architecture

### Custom Bridge Network

```yaml
networks:
  app-network:
    driver: bridge
```

Services communicate via DNS names matching container names:
- `postgresql-container` (db service)
- `php-fpm-container` (php service)
- `nginx-container` (webserver service)

### Port Bindings

| Service | Host Binding | Container Port | Purpose |
|---------|--------------|----------------|---------|
| webserver | 127.0.0.1:8080 | 80 | HTTP traffic |
| php | 127.0.0.1:9090 | 9000 | PHP-FPM debug |
| db | 127.0.0.1:2345 | 5432 | Direct DB access |

---

## Data Flow

### 1. Static Content Request

```
Browser → http://localhost:8080/index.html
        ↓
nginx container (port 80)
        ↓ (location /)
Checks /usr/share/nginx/html
        ↓
Returns index.html
```

### 2. PHP Dynamic Content Request

```
Browser → http://localhost:8080/index.php
        ↓
nginx container (port 80)
        ↓ (location ~ \.php$)
fastcgi_pass php-fpm-container:9000
        ↓
fastcgi_param SCRIPT_FILENAME /var/www/html/index.php
        ↓
php-fpm container (port 9000)
        ↓
PHP processor reads index.php
        ↓
Executes PHP code
        ↓
Returns HTML output
```

### 3. Database Query Request

```
Browser → http://localhost:8080/database.php
        ↓ (via php-fpm)
PHP executes pg_connect()
        ↓
host=postgresql-container port=5432
        ↓
PostgreSQL processes query
        ↓
Returns result to PHP
        ↓
PHP returns HTML
```

---

## Volume Management

### Application Volume

```yaml
volumes:
  - ./src:/var/www/html
```

Source code in `./src` on host is mounted to `/var/www/html` in php-fpm container. Changes to source files are immediately reflected without rebuilding.

### Database Volume

```yaml
volumes:
  - ./database/data:/var/lib/postgresql/data
```

Bind mount `./database/data` persists PostgreSQL data files on the host.

---

## Health Checks

| Service | Check Method | Interval | Timeout | Retries |
|---------|--------------|----------|---------|---------|
| db | pg_isready | 10s | 5s | 5 |
| php | pg_isready (via network) | 10s | 5s | 3 |
| webserver | curl -f | 10s | 5s | 3 |

Services with `depends_on` wait for health checks via `condition: service_healthy`.

---

## Security Architecture

### Network Isolation

- Custom bridge network `app-network` isolates services
- Only exposed ports bound to `127.0.0.1` (localhost)
- No direct inter-container access from host

### Secrets Management

- Database credentials in `.env` file (gitignored)
- Environment variables passed via `env_file`
- No credentials in Dockerfiles or source code

### Container Security

- Alpine-based images (minimal attack surface)
- No running services as root (future improvement)
- Read-only root filesystems (planned)

---

## Build Context

Each service has its own build context:

| Service | Context | Dockerfile |
|---------|---------|------------|
| database | ./database/ | postgresql.dockerfile |
| php | ./php/ | php.dockerfile |
| webserver | ./webserver/ | nginx.dockerfile |

This separation allows independent rebuilding and reduces build context size.

---

## Future Architecture Considerations

### Horizontal Scaling

- Add load balancer (nginx upstream) for multiple php-fpm instances
- Configure shared session storage (Redis)
- Implement read replicas for PostgreSQL

### High Availability

- Container restart policies for auto-recovery
- Health check guided service restart
- Database replication setup

### Monitoring

- Prometheus metrics exporter sidecar
- Structured logging to ELK stack
- Distributed tracing (Jaeger)