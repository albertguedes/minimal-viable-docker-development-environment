# Security Hardening Guide

Production security recommendations for the Minimal Viable Docker Development Environment.

---

## Container Security

### Non-Root Execution
All containers run as non-root users by design:

| Service | User | UID |
|---------|------|-----|
| nginx | nginx | 82 |
| php-fpm | www-data | 82 |
| postgresql | postgres | 999 |
| redis | redis | 100 |

### Read-Only Root Filesystem

Add to `compose.yaml` for production:

```yaml
php:
    read_only: true
    tmpfs:
        - /tmp:/tmp
```

### Drop Capabilities

```yaml
services:
    nginx:
        security_opt:
            - no-new-privileges:true
        cap_drop:
            - ALL
```

---

## Network Security

### Internal Network
All services communicate on internal `app-network`. Only nginx port 8080 is exposed.

### Firewall Rules

```bash
# Allow only necessary ports
ufw allow 8080/tcp    # nginx
ufw allow 2345/tcp     # PostgreSQL (if needed)
ufw deny 9090/tcp      # PHP-FPM (internal only)
```

### Service-to-Service Authentication

Use network policies to restrict communication:

```yaml
networks:
    app-network:
        driver: bridge
        attachable: true
```

---

## Secrets Management

### Docker Secrets (Swarm)

```bash
# Create secrets
echo "secure-password" | docker secret create db_password -
docker secret create db_user db_user.txt
docker secret create db_name db_name.txt

# Use in compose
secrets:
    db_password:
        external: true
    db_user:
        external: true
    db_name:
        external: true
```

### HashiCorp Vault Integration

For production, integrate with Vault:

```bash
# Fetch secret at startup
vault fetch secret/db/credentials - | docker secret create db_password -
```

### Environment Variable Protection

Never commit `.env` files. Use:
- `.env.example` with placeholder values
- Docker secrets for production
- Vault for enterprise deployments

---

## TLS/SSL Configuration

### Generate Certificates

```bash
# Self-signed (development)
./ssl/generate-ssl.sh

# Let's Encrypt (production)
certbot certonly --nginx -d example.com
```

### nginx SSL Configuration

```nginx
server {
    listen 443 ssl http2;
    ssl_certificate /etc/ssl/certs/server.crt;
    ssl_certificate_key /etc/ssl/private/server.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
}
```

### Redirect HTTP to HTTPS

```nginx
server {
    listen 80;
    return 301 https://$host$request_uri;
}
```

---

## Rate Limiting

### nginx Rate Limiting (already configured)

| Zone | Rate | Burst |
|------|------|-------|
| api_limit | 10r/s | 20 |
| general_limit | 30r/s | 50 |

### Additional nginx Protection

```nginx
# Block common attacks
location ~ /\.(git|svn|hg) {
    deny all;
}

# Size limits
client_max_body_size 10M;
client_body_buffer_size 128k;

# Timeout protection
client_body_timeout 10s;
client_header_timeout 10s;
```

---

## Fail2ban Intrusion Prevention

### Configuration

Filters in `fail2ban/` directory:
- `nginx-auth.conf` - Authentication failures
- `nginx-noscript.conf` - Script probing
- `nginx-req-limit.conf` - Rate limit abuse

### Setup on Host

```bash
# Install fail2ban
sudo apt install fail2ban

# Copy configuration
sudo cp fail2ban/jail.local /etc/fail2ban/jail.local

# Restart
sudo systemctl restart fail2ban
```

### Test Filters

```bash
# Test auth filter
fail2ban-regex /var/log/nginx/error.log fail2ban/filter.d/nginx-auth.conf

# Test regex
fail2ban-testcases nginx-auth
```

---

## Database Security

### PostgreSQL Hardening

```bash
# pg_hba.conf recommendations
# Use md5 or scram-sha-256 for authentication
# Restrict connections to app-network

# Add to postgresql.conf
ssl = on
ssl_cert_file = '/var/lib/postgresql/data/server.crt'
ssl_key_file = '/var/lib/postgresql/data/server.key'
```

### Redis Security

```bash
# Set password
redis-cli CONFIG SET requirepass "your-password"

# Use in compose
redis:
    command: redis-server --requirepass your-password
```

---

## Container Scanning

### Trivy Scanner

```bash
# Scan images
trivy image nginx:1.27-alpine
trivy image php:8.4-fpm-alpine
trivy image postgres:17-alpine

# Scan Dockerfiles
trivy config --scan .
```

### CI/CD Integration

Already configured in `.github/workflows/ci.yml` with:
- Trivy configuration scanning
- SARIF output to GitHub Security

---

## Logging and Monitoring

### Access Logs

```nginx
log_format main '$remote_addr - $remote_user [$time_local] '
                '"$request" $status $body_bytes_sent '
                '"$http_referer" "$http_user_agent"';

access_log /var/log/nginx/access.log main;
```

### Security Headers (already in ssl.conf)

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

---

## Backup Security

### Encrypted Backups

```bash
# Create backup
./backup/backup.sh

# Encrypt
gpg --encrypt --recipient your@email.com backup/postgresql_*.sql.gz

# Sign
gpg --sign backup/postgresql_*.sql.gz
```

### Offsite Backup

```bash
# Copy to S3
aws s3 cp backup/ s3://your-bucket/backups/ --storage-class GLACIER

# Copy to GCS
gsutil cp backup/ gs://your-bucket/backups/
```

---

## Compliance Checklist

- [ ] Non-root users configured
- [ ] SSL/TLS enabled
- [ ] Rate limiting active
- [ ] Fail2ban running
- [ ] Security headers set
- [ ] Secrets managed properly
- [ ] Backups configured
- [ ] Logging enabled
- [ ] Monitoring active
- [ ] Network isolated
- [ ] Resource limits set