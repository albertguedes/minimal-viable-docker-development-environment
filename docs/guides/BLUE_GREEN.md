# Blue-Green Deployment

Zero-downtime deployment strategy using two identical environments.

## Architecture

```
                 ┌─────────────┐
                 │   nginx     │
                 │  (router)   │
                 └──────┬──────┘
                        │
          ┌─────────────┴─────────────┐
          │                           │
    ┌─────▼─────┐               ┌─────▼─────┐
    │   blue    │               │   green   │
    │  (current)│               │  (staging)│
    └───────────┘               └───────────┘
```

## Quick Start

### 1. Initial Deployment (Blue)

```bash
# Deploy blue (current version)
docker compose -f compose.yaml up -d --env-file .env.blue
```

### 2. Deploy Green (New Version)

```bash
# Copy environment
cp .env.blue .env.green

# Update version/tag in .env.green
# IMAGE_TAG=v2.0.0

# Start green alongside blue
docker compose -f compose.yaml -f compose.green.yml up -d
```

### 3. Test Green

```bash
# Test new version
curl -H "Host: green.app.local" http://localhost:8080/
```

### 4. Switch Traffic

```bash
# Update nginx to point to green
# Update lb.conf upstream

# Reload nginx
docker compose exec webserver nginx -s reload
```

### 5. Remove Blue

```bash
# After verification, stop blue
docker compose -f compose.yaml -f compose.blue.yml down
```

## Docker Compose Green Config

```yaml
# compose.green.yml
services:
    db-green:
        image: postgres:17-alpine
        container_name: postgresql-green
        environment:
            - POSTGRES_DB=${POSTGRES_DB}
            - POSTGRES_USER=${POSTGRES_USER}
            - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
        profiles:
            - green

    php-green:
        image: php-fpm-image:v2
        container_name: php-fpm-green
        environment:
            - POSTGRES_HOST=postgresql-green
        depends_on:
            - db-green
        profiles:
            - green

    webserver-green:
        image: nginx-image:v2
        container_name: nginx-green
        profiles:
            - green
```

## Rolling Back

```bash
# If green fails, switch back to blue
# Update nginx to point to blue
docker compose exec webserver nginx -s reload

# Stop green
docker compose -f compose.yaml -f compose.green.yml down
```

## Automation Script

```bash
#!/bin/bash
# deploy-blue-green.sh

COLOR=${1:-green}

case $COLOR in
    blue)
        docker compose -f compose.yaml -f compose.blue.yml up -d
        ;;
    green)
        docker compose -f compose.yaml -f compose.green.yml up -d
        ;;
    switch)
        # Switch nginx upstream
        # Reload nginx
        ;;
    *)
        echo "Usage: $0 [blue|green|switch]"
        ;;
esac
```