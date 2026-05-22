# Minimal Viable Docker Development Environment

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub last commit](https://img.shields.io/github/last-commit/albertguedes/minimal-viable-docker-development-environment)](https://github.com/albertguedes/minimal-viable-docker-development-environment)
[![CI/CD](https://github.com/albertguedes/minimal-viable-docker-development-environment/actions/workflows/ci.yml/badge.svg)](https://github.com/albertguedes/minimal-viable-docker-development-environment/actions/workflows/ci.yml)

A production-ready, lightweight Docker development environment for teams requiring a consistent PHP + PostgreSQL stack. Built on Alpine Linux images for minimal footprint and fast deployments.

---

## Why This Project?

| Feature | Benefit |
|---------|---------|
| **Minimal Footprint** | Alpine-based images (~5MB base) for faster builds and lower resource usage |
| **Production-Ready** | Health checks, restart policies, and persistent storage out of the box |
| **Environment Isolation** | All credentials managed via environment variables, never in code |
| **Self-Documenting** | Clear service boundaries, dependency management, and architecture docs |
| **Enterprise Secure** | Ports bound to localhost, custom networks, no hardcoded secrets |
| **CI/CD Ready** | GitHub Actions workflows for testing, scanning, and release |

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    HOST MACHINE                          │
│                  (127.0.0.1:8080)                        │
└─────────────────────────┬───────────────────────────────┘
                          │
         ┌────────────────┴────────────────┐
         │                                 │
         ▼                                 ▼
┌─────────────────────┐         ┌─────────────────────┐
│  nginx-container     │         │   php-fpm-container │
│  (nginx:1.27-alpine) │────────▶│  (php:8.4-fpm)     │
│                      │         │                    │
│  Port: 80           │         │  Port: 9000        │
│  /usr/share/nginx/   │         │  /var/www/html     │
└─────────────────────┘         └─────────┬───────────┘
                                          │
                                          ▼
                              ┌─────────────────────┐
                              │ postgresql-container │
                              │  (postgres:17)      │
                              │                    │
                              │  Port: 5432        │
                              │  Volume: postgres-  │
                              │    data             │
                              └─────────────────────┘
```

## Services

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| **webserver** | nginx:1.27-alpine | 8080 | HTTP server, PHP proxy |
| **php** | php:8.4-fpm-alpine | 9090 | PHP-FPM FastCGI processor |
| **db** | postgres:17-alpine | 2345 | PostgreSQL database |

---

## Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- GNU Make 3.81+
- Composer 2.0+ (for running tests)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/albertguedes/minimal-viable-docker-development-environment.git
cd minimal-viable-docker-development-environment

# 2. Configure environment
cp .env.example .env
# Edit .env with your preferred credentials

# 3. Install PHP dependencies
composer install

# 4. Build and start services
make build && make up

# 5. Verify services
make test
```

### Verify Your Setup

```bash
# Test HTTP server
curl http://localhost:8080/

# Test PHP processing
curl http://localhost:8080/index.php

# Test database connection
curl http://localhost:8080/database.php

# Run unit tests
make test:unit

# Run integration tests
make test:integration

# View running containers
make logs

# Shell into PHP container
make shell service=php
```

---

## Developer Commands

| Command | Description |
|---------|-------------|
| `make up` | Start all containers in detached mode |
| `make down` | Stop all containers |
| `make build` | Rebuild Docker images |
| `make logs [service=<name>]` | View logs (all or specific service) |
| `make shell service=<db\|php\|webserver>` | Exec into container shell |
| `make clean` | Remove containers, volumes, and images |
| `make status` | Show running containers status |
| `make test` | Run all tests (curl + PHPUnit) |
| `make test:unit` | Run unit tests only |
| `make test:integration` | Run integration tests only |
| `make backup` | Backup database |
| `make restore file=<backup>` | Restore database from backup |

---

## Testing

### PHPUnit Tests

```bash
# Install dependencies
composer install

# Run all tests
composer test

# Run unit tests only
composer test:unit

# Run integration tests only
composer test:integration
```

### Test Suites

| Suite | Purpose | Location |
|------|---------|----------|
| **Unit** | PHP logic tests | `tests/Unit/` |
| **Integration** | HTTP endpoints + DB tests | `tests/Integration/` |

---

## Environment Variables

Configure your environment by editing the `.env` file:

```env
# PostgreSQL Configuration
POSTGRES_DB=dockerdb
POSTGRES_USER=docker
POSTGRES_PASSWORD=your_secure_password
```

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_DB` | dockerdb | Name of the database to create |
| `POSTGRES_USER` | docker | Database user |
| `POSTGRES_PASSWORD` | - | Database password (required) |

---

## Project Structure

```
.
├── src/                    # Application source code
│   ├── index.html         # Static HTML page
│   ├── index.php          # PHP info page
│   ├── database.php       # Database connection test
│   ├── health.php         # Health check endpoint
│   └── metrics.php        # JSON metrics endpoint
├── tests/                  # PHPUnit test suite
│   ├── bootstrap.php
│   ├── Unit/
│   └── Integration/
├── database/               # Database service
│   └── postgresql.dockerfile
├── php/                    # PHP service
│   └── php.dockerfile
├── webserver/              # Web server service
│   ├── nginx.dockerfile
│   └── nginx/
│       ├── default.conf   # Nginx configuration
│       └── nginx.conf     # Main config
├── backup/                 # Backup scripts
│   ├── backup.sh           # Backup with encryption/sync
│   ├── restore.sh          # Restore script
│   ├── verify-restore.sh   # Backup verification
│   └── config.sh          # Backup configuration
├── .github/
│   └── workflows/
│       ├── ci.yml         # CI pipeline (lint, test, scan, build)
│       └── cd.yml         # CD pipeline (tagged releases)
├── compose.yaml           # Service definitions
├── Makefile               # Developer commands
├── phpunit.xml.dist       # PHPUnit configuration
├── composer.json          # PHP dependencies
└── docs/                  # Documentation
    ├── ARCHITECTURE.md
    ├── CHANGELOG.md
    ├── USER_MANUAL.md
    └── TODO.md
```

---

## CI/CD

### GitHub Actions Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| **CI** | push to master, PR | Lint → Test (PHP 8.2/8.3/8.4) → Trivy scan → Build |
| **CD** | annotated tag `v*` | Build + push tagged images to registry |

### Secrets Required

Configure in GitHub repository settings:

| Secret | Description |
|--------|-------------|
| `DOCKER_REGISTRY_USERNAME` | Docker Hub username |
| `DOCKER_REGISTRY_TOKEN` | Docker Hub access token |

### Registry Configuration

Set in repository variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `DOCKER_REGISTRY` | docker.io | Docker registry URL |
| `DOCKER_IMAGE_NAME` | github.repository | Full image path |

---

## Troubleshooting

### Services won't start

```bash
# Check Docker is running
docker info

# View container logs
make logs

# Verify .env file exists
cat .env
```

### Database connection fails

```bash
# Wait for DB healthcheck to pass
make logs service=db

# Manually test connection inside PHP container
make shell service=php
pg_isready -h db -U docker
```

### Port already in use

```bash
# Find what's using port 8080
lsof -i :8080
# or
netstat -tulpn | grep 8080
```

---

## Backup & Restore

### Configuration

Edit `backup/config.local.sh` to configure your backup destination:

```bash
# Choose provider: local, s3, b2, rsync
BACKUP_PROVIDER=local

# Optional GPG encryption
# GPG_RECIPIENT="your@email.com"

# S3 Configuration (if BACKUP_PROVIDER=s3)
# S3_BUCKET="your-bucket"
# S3_REGION="us-east-1"

# Backblaze B2 (if BACKUP_PROVIDER=b2)
# B2_ACCOUNT_ID=""
# B2_APPLICATION_KEY=""
# B2_BUCKET=""
```

### Commands

```bash
# Backup database (local)
make backup

# Verify backup integrity
bash backup/verify-restore.sh

# Restore from backup
make restore file=backup/postgresql_20260522_120000.sql.gz
```

---

## Security Notes

- Ports are bound to `127.0.0.1` (localhost only) by default
- All credentials managed via environment variables
- No secrets committed to version control
- Custom Docker network for service isolation
- Named volumes for persistent data encryption at rest
- CI/CD includes Trivy vulnerability scanning
- Backups can be encrypted with GPG

**For production deployments**, consider:
- Implementing Docker Secrets
- Configuring SSL/TLS termination
- Adding a reverse proxy with automatic certificate management
- Enabling audit logging
- Setting resource limits and quotas

---

## Contributing

Contributions are welcome. Please see [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for guidelines.

---

## License

This project is distributed under the [MIT License](./LICENSE). See [LICENSE](./LICENSE) for more information.