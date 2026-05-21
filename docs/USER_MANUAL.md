# User Manual

Guide for deploying and operating the Minimal Viable Docker Development Environment.

---

## Overview

This project provides a containerized development environment with:

- **nginx** - HTTP web server
- **PHP-FPM** - PHP application processor
- **PostgreSQL** - Database server

All running in Docker containers with health checks, persistent storage, and environment-based configuration.

---

## Quick Start

### 1. Prerequisites

Install the following on your machine:

| Software | Minimum Version | Recommended |
|----------|-----------------|-------------|
| Docker Engine | 20.10+ | Latest |
| Docker Compose | 2.0+ | `docker compose` plugin |
| GNU Make | 3.81+ | Latest |
| Bash | 4.0+ | Latest |

Verify installations:

```bash
docker --version
docker compose version
make --version
```

### 2. Installation

```bash
# Clone repository
git clone https://github.com/albertguedes/minimal-viable-docker-development-environment.git
cd minimal-viable-docker-development-environment

# Configure environment
cp .env.example .env
nano .env  # or use your preferred editor
```

### 3. Start Services

```bash
# Build images and start containers
make build && make up

# Verify services are running
make status
```

### 4. Access Services

| Service | URL | Description |
|---------|-----|-------------|
| Web Server | http://localhost:8080/ | nginx welcome page |
| PHP Info | http://localhost:8080/index.php | PHP configuration |
| Database Test | http://localhost:8080/database.php | PostgreSQL connection test |

### 5. Stop Services

```bash
make down
```

---

## Configuration

### Environment Variables

Edit the `.env` file to configure your environment:

```env
POSTGRES_DB=dockerdb
POSTGRES_USER=docker
POSTGRES_PASSWORD=your_secure_password_here
```

| Variable | Description | Required |
|----------|-------------|----------|
| `POSTGRES_DB` | Database name | Yes |
| `POSTGRES_USER` | Database username | Yes |
| `POSTGRES_PASSWORD` | Database password | Yes |

### Database Credentials

The database credentials must match between your `.env` file and your application code. The PHP application reads from environment variables automatically.

---

## Operations

### Starting/Stopping

```bash
make up      # Start all services
make down    # Stop all services
make status  # Show running containers
```

### Viewing Logs

```bash
make logs               # All services
make logs service=db   # Database logs only
make logs service=php   # PHP logs only
make logs service=webserver  # nginx logs only
```

### Shell Access

```bash
make shell service=php  # PHP container shell
make shell service=db   # PostgreSQL shell
make shell service=webserver  # nginx shell
```

### Rebuilding

```bash
make build  # Rebuild Docker images
```

Use this after changing Dockerfiles or compose.yaml.

### Clean Start

Removes all containers, volumes, and images:

```bash
make clean
make build && make up
```

---

## Direct Database Access

### Connect from Host

```bash
psql -h localhost -p 2345 -U docker -d dockerdb
```

When prompted, enter the password from your `.env` file.

### Connect from PHP Container

```bash
make shell service=php
psql -h postgresql-container -U docker -d dockerdb
```

---

## Data Persistence

### Volume Mounts

| Volume | Host Path | Container Path | Purpose |
|--------|-----------|----------------|---------|
| Volume Mount | `./database/data` | `/var/lib/postgresql/data` | PostgreSQL data |
| `src` | `./src` | `/var/www/html` | Application files |

### Backing Up Database

```bash
# Create backup
docker exec postgresql-container pg_dump -U docker dockerdb > backup.sql

# Restore backup
docker exec -i postgresql-container psql -U docker dockerdb < backup.sql
```

### Resetting Database

```bash
make down
docker volume rm minimal_viable_postgres-data  # No longer needed with bind mount
make up
```

**Warning**: This deletes all data.

---

## Network Configuration

### Port Bindings

| Service | Host | Container | Protocol |
|---------|------|-----------|----------|
| nginx | 127.0.0.1:8080 | 80 | HTTP |
| php-fpm | 127.0.0.1:9090 | 9000 | FastCGI |
| postgresql | 127.0.0.1:2345 | 5432 | PostgreSQL |

All ports bind to `127.0.0.1` (localhost only) for security.

### Container Communication

Containers communicate via DNS names on the `app-network` Docker network:

| From | To | DNS Name |
|------|----|----------|
| nginx | php-fpm | `php-fpm-container` |
| php-fpm | postgresql | `postgresql-container` |

---

## Troubleshooting

### Services Won't Start

1. Check Docker is running:
   ```bash
   docker info
   ```

2. Verify `.env` exists:
   ```bash
   ls -la .env
   ```

3. Check port availability:
   ```bash
   lsof -i :8080
   ```

4. View logs:
   ```bash
   make logs
   ```

### Database Connection Errors

1. Wait 30 seconds for database initialization
2. Verify credentials in `.env`
3. Check database health:
   ```bash
   make status
   ```
4. Test connection:
   ```bash
   curl http://localhost:8080/database.php
   ```

### Permission Issues

If you encounter permission errors with mounted files:

```bash
# Fix ownership
sudo chown -R $(id -u):$(id -g) src/
```

### Container Health Check Failures

```bash
# Check health status
docker compose ps

# View specific logs
make logs service=php

# Restart specific service
docker compose restart php
```

---

## Security Recommendations

### For Development

- Use strong passwords in `.env`
- Never commit `.env` to version control
- Use `make clean` when done working

### For Production

This project includes production hardening features (Phase 1):

1. **SSL/TLS**: Configure HTTPS - run `./ssl/generate-ssl.sh` and update nginx config
2. **Docker Secrets**: Use Swarm secrets via `secrets/docker-secrets.env.example`
3. **Rate Limiting**: nginx is pre-configured with API (10r/s) and general (30r/s) limits
4. **Resource Limits**: Memory and CPU limits are configured per service
5. **Backup Strategy**: Use `./backup/backup.sh` for automated backups
6. **Intrusion Prevention**: Fail2ban filters available in `fail2ban/` directory
7. **Monitoring**: Deploy with `monitoring/docker-compose.monitoring.yml` or `docker-compose.logging.yml`

#### Production Deployment

```bash
# Start with monitoring stack
docker compose -f compose.yaml -f monitoring/docker-compose.monitoring.yml up -d

# Generate SSL certificates
./ssl/generate-ssl.sh

# Create backups before updates
./backup/backup.sh
```

#### Monitoring

Access monitoring tools at:

| Service | URL |
|---------|-----|
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |
| Kibana | http://localhost:5601 |
| Uptime Kuma | http://localhost:3001 |

Default Grafana credentials: `admin` / `admin`

---

## Testing

Run the test suite to verify your setup:

```bash
make test
```

Individual tests:

```bash
make test-validate   # Validate configuration
make test-health     # Check service health
make test-http       # Test HTTP endpoints
make test-db         # Test database connection
```

---

## Getting Help

| Issue | Action |
|-------|--------|
| Documentation | See [README.md](../README.md) |
| Problems/Bugs | Open a GitHub Issue |
| Contributing | See [CONTRIBUTING.md](../CONTRIBUTING.md) |

---

## License

This project is distributed under the MIT License. See [LICENSE](../LICENSE).