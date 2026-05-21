# User Manual

## Quick Start

```bash
# 1. Clone and enter directory
git clone https://github.com/albertguedes/minimal-viable-docker-development-environment.git
cd minimal-viable-docker-development-environment

# 2. Configure environment
cp .env.example .env
# Edit .env with your database credentials

# 3. Build and start
make build && make up

# 4. Verify
curl http://localhost:8080/
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| nginx | 8080 | HTTP server |
| php-fpm | 9090 | PHP FastCGI (debug) |
| postgresql | 2345 | Database |

## Common Commands

```bash
make up          # Start containers
make down        # Stop containers
make build       # Rebuild images
make logs        # View logs
make shell       # Shell into container (service=php|db|webserver)
make clean       # Remove everything
make test        # Run tests
make backup      # Backup database
```

## Endpoints

| URL | Description |
|-----|-------------|
| http://localhost:8080/ | Static HTML |
| http://localhost:8080/index.php | PHP info |
| http://localhost:8080/database.php | Database test |
| http://localhost:8080/health | Health check |
| http://localhost:8080/metrics.php | JSON metrics |

## Troubleshooting

**Services won't start:**
```bash
docker compose ps
make logs
cat .env
```

**Database connection fails:**
```bash
make shell service=php
pg_isready -h postgresql-container -U docker
```

**Port already in use:**
```bash
lsof -i :8080
```