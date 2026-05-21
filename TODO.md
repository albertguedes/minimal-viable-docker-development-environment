# TODO

## Phase 1: Production Hardening (v0.3.0) - DONE

### Security
- [x] Add non-root user to all containers
- [x] Implement Docker Secrets for production
- [x] Add rate limiting to nginx
- [x] Configure SSL/TLS support
- [x] Add fail2ban or similar intrusion prevention

### Reliability
- [x] Configure log rotation for all services
- [x] Add resource limits (memory/CPU)
- [x] Implement database backup strategy
- [x] Add auto-restart on failure conditions

### Monitoring
- [x] Add Prometheus metrics exporter
- [x] Add Grafana dashboards
- [x] Configure log aggregation (ELK stack or similar)
- [x] Add uptime monitoring

## Phase 2: Developer Experience (v0.4.0) - DONE

### Local Development
- [x] Add PHP xdebug configuration (removed in v0.5.0)
- [x] Add hot-reload for PHP files
- [x] Add mailhog/mailhog for local email testing (removed in v0.5.0)
- [x] Configure persistent logs

### Testing
- [x] Add integration tests
- [x] Add docker-compose validation tests
- [x] Add database migration tests
- [x] Configure CI/CD pipeline

### Documentation
- [x] Add troubleshooting guide
- [x] Add API documentation template
- [x] Add deployment guide for major cloud providers
- [x] Add security hardening guide

## v0.5.0 - Minimal Viability

Simplified to core stack: nginx + php-fpm + postgresql only.

## v0.6.0 - Phase 3: Enterprise Features

### Multi-Environment
- [x] compose.env.staging.yml - Staging environment
- [x] compose.env.production.yml - Production environment

### Scalability
- [x] compose.scale.yml - Horizontal scaling with nginx load balancer
- [x] scale/lb.conf - nginx upstream configuration

### Compliance
- [x] compose.audit.yml - PostgreSQL audit logging
- [x] audit/pg_audit.conf - Audit configuration
- [x] docs/guides/SECRETS_ROTATION.md - Secrets rotation guide
- [x] docs/guides/BLUE_GREEN.md - Blue-green deployment guide

### Optional Stacks Available
- backup, monitoring, security, perf, audit, scale, env.staging, env.production