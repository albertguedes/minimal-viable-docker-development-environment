# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v0.10.1] - 2026-05-22

### Fixed
- CD workflow: invalid YAML indentation on Buildx step
- CD workflow: PHP image build uses repository root context (matches CI)
- Backup scripts: default container name `mv-postgresql-container`
- `backup/test_backup.sh`: portable `SCRIPT_DIR` (no hardcoded path)
- PHP fallbacks in `database.php` and `metrics.php` use `127.0.0.1`
- `DatabaseTest` default port `5432` (was `2345`)
- Makefile: single `logs` target with optional `service=`
- `compose.yaml`: removed ignored `ports` under host network

### Changed
- Documentation: `ARCHITECTURE.md`, README, and `USER_MANUAL` aligned with host networking

## [v0.10.0] - 2026-05-22

### Changed
- **Host-Independent Docker Environment**: Application now runs entirely in Docker containers
  - PHP image includes: composer, PHPUnit 11, PDO pgsql, pgsql extensions
  - Removed: `composer.json`, `composer.lock`, `vendor/` (no longer needed on host)
  - Tests moved to `php/tests/` (volume-mounted into container at runtime)
  - `phpunit.xml.dist` moved to `php/` (volume-mounted)
  - Multi-version PHP support (8.2, 8.3, 8.4) via `--build-arg PHP_VERSION=x.x`
- **CI Pipeline Refactored**: Tests now run inside PHP container via `docker compose run`
- **Makefile**: Updated to use `docker compose run --rm php phpunit` for testing
- **compose.yaml**: PHP service uses build args for version, volumes for tests

### Removed
- Host machine requirement for PHP/Composer (now only Docker required)
- Network mode bridge (all services now use `host` mode)

## [v0.9.0] - 2026-05-22

### Added
- **PHPUnit Testing**: Full test suite with Unit and Integration tests
  - `phpunit.xml.dist` - PHPUnit configuration
  - `tests/bootstrap.php` - Test bootstrap
  - `tests/Unit/ExampleTest.php` - Basic unit tests
  - `tests/Integration/HealthCheckTest.php` - HTTP endpoint tests
  - `tests/Integration/DatabaseTest.php` - PostgreSQL connection tests
- **GitHub Actions CI/CD**:
  - `.github/workflows/ci.yml` - Lint, test (PHP 8.2/8.3/8.4), Trivy scan, Docker build
  - `.github/workflows/cd.yml` - Tagged release workflow
- **Composer Support**: `composer.json` with PHPUnit 11.x
- **Enhanced Backup**:
  - `backup/config.sh` - Configurable backup providers (local, S3, B2, rsync)
  - `backup/backup.sh` - GPG encryption + off-site sync support
  - `backup/verify-restore.sh` - Automated backup integrity verification

### Changed
- Makefile: Added `test:unit` and `test:integration` targets
- Makefile: Updated `make test` to run both curl tests and PHPUnit
- Makefile: Fixed `make shell` container names to use `mv-*` prefix
- Updated README with CI/CD badges, testing section, and backup documentation

### Security
- CI pipeline includes Trivy vulnerability scanning
- Backup encryption with GPG (optional, configurable)
- All secrets gitignored, no hardcoded credentials

## [v0.9.1] - 2026-05-22

### Fixed
- CI: POSTGRES_HOST from 'postgres' to 'db' (matches compose service name)
- CI: Removed --no-colors flag (not supported in PHPUnit 11)
- CI: Added pgsql PHP extension for pg_* functions
- CI: Removed hadolint lint job (permissions issues with multiline dockerfile)
- CI: Updated build job needs from [lint, test, trivy] to [test, trivy]
- php.dockerfile: Removed --no-cache flag to fix DL3018 warning

## [v0.8.4] - 2026-05-22

### Fixed
- nginx default.conf: fastcgi_pass now uses `php:9000` (service name) instead of container name
- php.dockerfile: removed redundant chown (base image already has www-data)
- backup/backup.sh: mkdir reordered before path validation (race condition fix)
- src/index.html: fixed unclosed h1 tag
- crontab.txt: made portable with dynamic path detection

### Added
- src/health.php: new dedicated health check endpoint
- VERSION: synced to v0.8.3

### Updated
- AGENT.md: container naming standardized to `mv-*` prefix, network name to `mv-network`
- docs/ARCHITECTURE.md: container and network naming updated throughout

## [v0.8.3] - 2026-05-21

### Fixed
- compose.yaml: Removed redundant environment variables (already in env_file)
- backup/restore.sh: Added path validation for backup files
- src/index.php: Replaced phpinfo() with minimal status page

## [v0.8.2] - 2026-05-21

### Added
- backup/test_backup.sh - Comprehensive tests for backup/restore scripts
- Makefile: `make test-backup` - Run backup script tests

### Changed
- Makefile test: fixed shell variable `$$` expansion to literal values

## [v0.8.1] - 2026-05-21

### Fixed
- Makefile: `make shell` correctly maps service names to container names (db→postgresql-container, webserver→nginx-container)
- Makefile: `make test` now uses correct `/metrics.php` endpoint
- .env.example: Fixed password mismatch (docker123→docker)
- nginx/default.conf: Fixed inconsistent document root (now uses /var/www/html for both static and PHP)
- php.dockerfile: removed redundant `adduser` (Alpine www-data already exists)
- backup/backup.sh: Added `-h localhost` to pg_dump for explicit TCP connection
- backup/backup.sh: Added path validation before `-delete`
- backup/restore.sh: Added safety backup before restore
- src/metrics.php: Fixed SQL injection risk with parameterized query
- crontab.txt: Added note about editing absolute path
- compose.yaml: PHP healthcheck now includes `-d ${POSTGRES_DB}` flag
- compose.yaml: PHP service now has explicit `env_file: .env`
- compose.yaml: webserver now mounts `./src:/var/www/html:ro` to serve static files

## [v0.8.0] - 2025-05-21

### Minimal Viable Architecture
Only 3 containers: **nginx + php-fpm + postgresql**

### Host-based Services
No more container bloat:
- Backup: `backup/backup.sh` + cron
- Monitoring: `src/metrics.php` (JSON endpoint)
- Fail2ban: Host installation (`security/jail.local`)
- Uptime: Cron (`crontab.txt`)

### Removed
All extra compose files and containers:
- prometheus, grafana, db-exporter
- fail2ban, uptime-kuma containers
- All `compose.*.yml` override files

### New Files
- `src/metrics.php` - JSON metrics endpoint
- `backup/backup.sh` - Cron-friendly backup
- `backup/restore.sh` - Restore script
- `security/jail.local` - Fail2ban config
- `crontab.txt` - Cron jobs

## [v0.7.0] - 2025-05-21

Profiles reorganization.

## [v0.6.0] - 2025-05-21

Enterprise features.

## [v0.5.0] - 2025-05-21

Minimal stack only.

## [v0.3.0] - [v0.4.0] - Previous phases

Phase 1-2 features.