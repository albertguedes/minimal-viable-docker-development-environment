# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.4.0] - 2025-05-21

### Local Development
- **PHP Xdebug**: Added xdebug 3 configuration with `php/xdebug.ini`
- **Mailhog**: Added Mailhog for local email testing (ports 8025, 1025)
- **Hot-reload**: PHP files auto-reload via volume mount

### Testing
- **CI/CD Pipeline**: Added GitHub Actions workflow (`.github/workflows/ci.yml`)
- **Integration tests**: Added `tests/test-compose.yml`
- **Database migrations**: Added `migrations/` with `001_initial_schema.sql`, `002_add_sessions.sql`
- **Migration runner**: Added `migrations/migrate.sh`

### Documentation
- **Troubleshooting guide**: Added `docs/guides/TROUBLESHOOTING.md`
- **API template**: Added `docs/guides/API_TEMPLATE.md`
- **Deployment guide**: Added `docs/guides/DEPLOYMENT.md` (AWS, GCP, Azure, Swarm, Kubernetes)
- **Security hardening guide**: Added `docs/guides/SECURITY_HARDENING.md`

### Removed
- **Redis**: Removed (PostgreSQL can handle caching/sessions for minimal projects)

### Updated Files
- `php/php.dockerfile` - Added xdebug (removed redis)
- `compose.yaml` - Removed redis service
- `docs/DEVELOPER_GUIDE.md` - Updated service list
- `.gitignore` - Updated for new directories

## [v0.3.0] - 2025-05-21

### Security
- **Non-root containers**: Added `www-data` user for PHP, `nginx` user for nginx, `postgres` user for database
- **Docker Secrets**: Added `secrets/docker-secrets.env.example` template for Swarm mode
- **Rate limiting**: Configured nginx with `limit_req_zone` for API (10r/s) and general (30r/s) endpoints
- **SSL/TLS**: Added `ssl.conf` with TLS 1.2/1.3, secure ciphers, and security headers
- **Fail2ban**: Added intrusion prevention with filters for auth failures, missing scripts, and req limits

### Reliability
- **Log rotation**: Configured JSON logging with 10MB max size and 3 files per service
- **Resource limits**: Added memory and CPU limits/reservations for all containers
- **Database backup**: Added automated backup script with 7-day retention and restore script
- **Auto-restart**: All services already configured with `restart: unless-stopped`

### Monitoring
- **Prometheus**: Added `prometheus.yml` configuration with scrape targets
- **Grafana**: Added `docker-compose.monitoring.yml` with Prometheus + Grafana + postgres_exporter
- **ELK stack**: Added `docker-compose.logging.yml` with Elasticsearch + Logstash + Kibana
- **Uptime monitoring**: Added Uptime Kuma to logging compose

### Added Files
- `ssl/generate-ssl.sh` - Self-signed certificate generator
- `fail2ban/filter.d/*.conf` - Fail2ban filters
- `fail2ban/jail.local` - Fail2ban jail configuration
- `backup/backup.sh` - PostgreSQL backup script
- `backup/restore.sh` - PostgreSQL restore script
- `monitoring/prometheus.yml` - Prometheus scrape config
- `monitoring/docker-compose.monitoring.yml` - Monitoring stack
- `monitoring/docker-compose.logging.yml` - ELK + Uptime Kuma stack

## [v0.2.0] - 2025-05-21

### Added
- **Environment variables**: `.env` file support via `env_file` in compose
- **Environment template**: `.env.example` with documented variables
- **Health checks**: All services now have healthcheck configurations
- **Restart policies**: Services configured with `restart: unless-stopped`
- **Custom network**: `app-network` bridge network for service isolation
- **Data persistence**: Host bind mount `database/data/` for PostgreSQL
- **Makefile**: Developer commands (up, down, build, logs, shell, clean, test)
- **Test suite**: validate-compose, test-health, test-http, test-db
- **AGENTS.md**: Developer instructions for future sessions
- **docs/**: DEVELOPER_GUIDE.md and USER_MANUAL.md

### Changed
- **Security**: Database credentials now loaded from environment variables
- **Ports binding**: All ports bound to `127.0.0.1` (localhost only)
- **Image versions**: Updated to latest (postgres:17-alpine, php:8.4-fpm-alpine, nginx:1.27-alpine)
- **PHP extension**: Added `pdo_pgsql` alongside `pgsql`
- **src/database.php**: Now reads credentials from environment variables
- **Directory structure**: `app/` → `src/`, `db/` → `database/`
- **Compose file**: `docker-compose.yml` → `compose.yaml`
- **Compose version**: Removed obsolete `version` attribute

### Deprecated
- **dockli script**: Removed in favor of `make shell service=php`

### Removed
- **Hardcoded credentials**: Removed from `database/postgresql.dockerfile`
- **Public port exposure**: Ports no longer exposed to all interfaces

## [v0.1.0] - 2022-12-07

### Added
- Initial release with nginx, php-fpm, and postgresql containers
- Basic compose setup
- Sample PHP files for testing
- README with installation instructions