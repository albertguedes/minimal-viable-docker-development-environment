# Troubleshooting Guide

Solutions for common issues with the Minimal Viable Docker Development Environment.

---

## Services Won't Start

### Symptoms
Containers fail to start or exit immediately.

### Diagnosis

```bash
# Check container status
docker compose ps

# View logs for specific service
docker compose logs db
docker compose logs php
docker compose logs webserver

# Check Docker resources
docker system df
docker stats --no-stream
```

### Solutions

1. **Port conflicts**: Stop other services using ports 8080, 9090, 2345, 6379, 8025, 1025
2. **Disk space**: Clean up with `docker system prune -a`
3. **Memory limits**: Increase Docker memory allocation in Docker Desktop settings
4. **Permissions**: Run `sudo chown -R $(id -u):$(id -g) database/data/`

---

## Database Connection Failures

### Symptoms
PHP cannot connect to PostgreSQL, `database.php` returns error.

### Diagnosis

```bash
# Check database logs
docker compose logs db | grep -i error

# Test connectivity from host
psql -h localhost -p 2345 -U docker -d dockerdb

# Test from PHP container
docker exec php-fpm-container pg_isready -h postgresql-container -U docker
```

### Solutions

1. **Wait for initialization**: Database needs ~30s to initialize on first start
2. **Check credentials**: Verify `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` in `.env`
3. **Health check timeout**: Increase `start_period` in `compose.yaml`
4. **Volume permissions**: `chmod 777 database/data/`

---

## PHP Xdebug Not Connecting

### Symptoms
IDE breakpoint not hitting, Xdebug not connecting.

### Diagnosis

```bash
# Check Xdebug is loaded
docker exec php-fpm-container php -m | grep xdebug

# Check environment variables
docker exec php-fpm-container env | grep XDEBUG
```

### Solutions

1. **Ensure `host.docker.internal` resolves**: Add to `/etc/hosts`: `172.17.0.1 host.docker.internal`
2. **Firewall**: Ensure port 9003 is open on host
3. **IDE configuration**: Use correct `pathMappings`:
   ```json
   {
       "pathMappings": {
           "/var/www/html": "${workspaceFolder}/src"
       }
   }
   ```
4. **Trigger mode**: Set `xdebug.start_with_request = trigger` in `xdebug.ini`, then add `?XDEBUG_SESSION_START=1` to URL

---

## Redis Connection Failures

### Symptoms
PHP Redis extension not working.

### Diagnosis

```bash
# Test Redis connectivity
docker exec redis-container redis-cli ping
```

### Solutions

1. **Check Redis environment**: Ensure `REDIS_HOST=redis-container` is set
2. **Extension loaded**: `docker exec php-fpm-container php -m | grep redis`
3. **Rebuild PHP image**: `docker compose build php && docker compose up -d php`

---

## Nginx 502 Bad Gateway

### Symptoms
PHP pages return 502 error.

### Diagnosis

```bash
docker compose logs php
docker compose logs webserver
```

### Solutions

1. **PHP container unhealthy**: Check `docker compose ps` - restart PHP if unhealthy
2. **FastCGI config**: Verify `fastcgi_pass php-fpm-container:9000;` in `nginx/default.conf`
3. **Volume mount**: Ensure `./src` is properly mounted to PHP container

---

## File Changes Not Reflecting

### Symptoms
Changes to PHP files not showing up.

### Solutions

1. **OPcache**: Add to `src/index.php` or create `src/opcache.ini`:
   ```ini
   opcache.enable=0
   ```
2. **Hard refresh**: `Ctrl+Shift+R` in browser
3. **Volume mount issue**: Verify mount with `docker exec php-fpm-container ls -la /var/www/html`

---

## Mailhog Not Receiving Emails

### Symptoms
Application emails not appearing in Mailhog.

### Solutions

1. **Check Mailhog status**: http://localhost:8025
2. **SMTP configuration**: Set PHP mail config:
   ```php
   ini_set('SMTP', 'mailhog-container');
   ini_set('smtp_port', '1025');
   ```
3. **Verify network**: `docker exec php-fpm-container ping mailhog-container`

---

## Docker Build Failures

### Symptoms
`docker compose build` fails.

### Solutions

1. **Clear build cache**: `docker compose build --no-cache`
2. **Build arguments**: Check required `ARG` values in Dockerfiles
3. **Alpine packages**: Some packages may have changed - check `apk` commands

---

## Performance Issues

### Slow Response Times

1. **Resource limits**: Check `deploy.resources.limits` in `compose.yaml`
2. **Database queries**: Enable query logging in PostgreSQL
3. **Redis cache**: Use Redis for session management:
   ```php
   ini_set('session.save_handler', 'redis');
   ini_set('session.save_path', 'tcp://redis-container:6379');
   ```

### High Memory Usage

```bash
# Check container memory
docker stats --no-stream

# Reduce PostgreSQL memory:
# Add to database/postgresql.dockerfile:
# ENV POSTGRES_SHARED_BUFFERS=128MB
```

---

## Reset Everything

```bash
# Complete reset
make down
docker system prune -a -f
docker volume prune -f
make build && make up
```

---

## Getting Help

| Issue | Resource |
|-------|----------|
| Container logs | `docker compose logs -f [service]` |
| Health status | `docker compose ps` |
| Network issues | `docker network inspect minimal_viable_app-network` |
| Volume permissions | `ls -la database/data/` |