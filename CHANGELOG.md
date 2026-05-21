# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.6.0] - 2025-05-21

### Multi-Environment
- `compose.env.staging.yml` - Staging environment config
- `compose.env.production.yml` - Production environment config

### Scalability
- `compose.scale.yml` - Horizontal scaling support
- `scale/lb.conf` - nginx load balancer upstream

### Compliance & Enterprise
- `compose.audit.yml` - PostgreSQL audit logging
- `docs/guides/SECRETS_ROTATION.md` - Secrets rotation guide
- `docs/guides/BLUE_GREEN.md` - Blue-green deployment guide

### Optional Stacks
All stacks now available as compose overrides:
- `backup` - Database backup/restore
- `monitoring` - Prometheus + Grafana
- `security` - Fail2ban + Uptime Kuma
- `perf` - PHP opcache + nginx cache
- `audit` - PostgreSQL audit logging
- `scale` - Horizontal scaling
- `env.staging` / `env.production` - Environment profiles

## [v0.5.0] - 2025-05-21

### Minimal Stack
Only nginx, php-fpm, postgresql.

## [v0.4.0] - 2025-05-21

Phase 2 development experience improvements.

## [v0.3.0] - 2025-05-21

Phase 1 production hardening.

## [v0.2.0] - 2025-05-21

Environment variables, health checks, restart policies.

## [v0.1.0] - 2022-12-07

Initial release with nginx, php-fpm, and postgresql.