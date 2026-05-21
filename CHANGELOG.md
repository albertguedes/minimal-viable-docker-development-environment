# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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