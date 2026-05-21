# User Manual

Guide for deploying and operating the Minimal Viable Docker Development Environment.

---

## Overview

A minimal containerized development environment with:

- **nginx** - HTTP web server
- **PHP-FPM** - PHP application processor
- **PostgreSQL** - Database server

---

## Quick Start

### 1. Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- GNU Make 3.81+

### 2. Installation

```bash
git clone <repo-url>
cd minimal-viable-docker-development-environment
cp .env.example .env
```

### 3. Start

```bash
make build && make up
```

### 4. Access

| Service | URL |
|---------|-----|
| Web Server | http://localhost:8080/ |
| PHP Info | http://localhost:8080/index.php |
| Database Test | http://localhost:8080/database.php |

### 5. Stop

```bash
make down
```

---

## Configuration

Edit `.env`:

```env
POSTGRES_DB=dockerdb
POSTGRES_USER=docker
POSTGRES_PASSWORD=your_password
```

---

## Commands

```bash
make up      # Start services
make down    # Stop services
make build   # Rebuild images
make logs    # View logs
make shell   # Shell access (service=php|db|webserver)
make clean   # Remove everything
make test    # Run tests
```

---

## Direct Database Access

```bash
psql -h localhost -p 2345 -U docker -d dockerdb
```

---

## Data Persistence

| Host Path | Container Path | Purpose |
|-----------|----------------|---------|
| `./database/data` | `/var/lib/postgresql/data` | PostgreSQL data |
| `./src` | `/var/www/html` | Application files |

---

## Troubleshooting

### Services Won't Start

1. Check Docker is running: `docker info`
2. Verify `.env` exists
3. Check port availability: `lsof -i :8080`
4. View logs: `make logs`

### Database Connection Errors

1. Wait 30 seconds for initialization
2. Verify credentials in `.env`
3. Test: `curl http://localhost:8080/database.php`

---

## Security

For development:
- Use strong passwords in `.env`
- Never commit `.env` to version control

For production:
- Configure SSL/TLS
- Use Docker Secrets
- Enable firewall rules

---

## License

MIT License. See LICENSE file.