# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.8.1] - 2026-05-21

### Fixed
- Makefile: `make test` now uses correct `/metrics.php` endpoint
- php.dockerfile: removed redundant `adduser` (Alpine www-data already exists)

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