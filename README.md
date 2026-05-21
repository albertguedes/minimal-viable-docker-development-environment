# Minimal Viable Docker Development Environment

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub last commit](https://img.shields.io/github/last-commit/albertguedes/minimal-viable-docker-development-environment)](https://github.com/albertguedes/minimal-viable-docker-development-environment)

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

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    HOST MACHINE                        │
│                  (127.0.0.1:8080)                       │
└─────────────────────────┬───────────────────────────────┘
                          │
         ┌────────────────┴────────────────┐
         │                                 │
         ▼                                 ▼
┌─────────────────────┐         ┌─────────────────────┐
│  nginx-container    │         │   php-fpm-container │
│  (nginx:1.27-alpine)│────────▶│  (php:8.4-fpm)     │
│                     │         │                    │
│  Port: 80           │         │  Port: 9000        │
│  /usr/share/nginx/  │         │  /var/www/html     │
└─────────────────────┘         └─────────┬───────────┘
                                          │
                                          ▼
                              ┌─────────────────────┐
                              │ postgresql-container │
                              │  (postgres:17)      │
                              │                    │
                              │  Port: 5432         │
                              │  Volume: postgres-   │
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

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/albertguedes/minimal-viable-docker-development-environment.git
cd minimal-viable-docker-development-environment

# 2. Configure environment
cp .env.example .env
# Edit .env with your preferred credentials

# 3. Build and start services
make build && make up

# 4. Verify services
curl http://localhost:8080/
```

### Verify Your Setup

```bash
# Test HTTP server
curl http://localhost:8080/

# Test PHP processing
curl http://localhost:8080/index.php

# Test database connection
curl http://localhost:8080/database.php

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
│   ├── index.php         # PHP info page
│   └── database.php      # Database connection test
├── database/              # Database service
│   └── postgresql.dockerfile
├── php/                   # PHP service
│   └── php.dockerfile
├── webserver/             # Web server service
│   ├── nginx.dockerfile
│   └── nginx/
│       └── default.conf  # Nginx configuration
├── compose.yaml          # Service definitions
├── Makefile              # Developer commands
├── CHANGELOG.md          # Version history
└── TODO.md               # Planned improvements
```

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
pg_isready -h postgresql-container -U docker
```

### Port already in use

```bash
# Find what's using port 8080
lsof -i :8080
# or
netstat -tulpn | grep 8080
```

---

## Security Notes

- Ports are bound to `127.0.0.1` (localhost only) by default
- All credentials managed via environment variables
- No secrets committed to version control
- Custom Docker network for service isolation
- Named volumes for persistent data encryption at rest

**For production deployments**, consider:
- Implementing Docker Secrets
- Configuring SSL/TLS termination
- Adding a reverse proxy with automatic certificate management
- Enabling audit logging
- Setting resource limits and quotas

---

## Contributing

Contributions are welcome. Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

---

## License

This project is distributed under the [MIT License](./LICENSE). See [LICENSE](./LICENSE) for more information.