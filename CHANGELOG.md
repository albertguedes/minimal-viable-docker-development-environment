# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.5.0] - 2025-05-21

### Minimal Stack
Only nginx, php-fpm, postgresql.

### Optional Stacks (compose overrides)
- `compose.backup.yml` - Database backup/restore
- `compose.monitoring.yml` - Prometheus + Grafana
- `compose.security.yml` - Fail2ban + Uptime Kuma
- `compose.perf.yml` - PHP opcache + nginx cache

Usage: `docker compose -f compose.yaml -f compose.<stack>.yml up -d`

### Removed
- Redis, Mailhog, Xdebug (bloat for minimal projects)

## [v0.4.0] - 2025-05-21

Phase 2 development experience improvements.

## [v0.3.0] - 2025-05-21

Phase 1 production hardening.

## [v0.2.0] - 2025-05-21

Environment variables, health checks, restart policies.

## [v0.1.0] - 2022-12-07

Initial release with nginx, php-fpm, and postgresql.