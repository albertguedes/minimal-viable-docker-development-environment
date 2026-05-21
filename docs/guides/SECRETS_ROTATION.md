# Secrets Rotation

## Docker Secrets

### Create Secrets

```bash
# Create database password
echo "new-password-$(date +%s)" | docker secret create db_password -

# Create database user
echo "appuser" | docker secret create db_user -

# List secrets
docker secret ls
```

### Update Secrets

```bash
# Create new secret
echo "new-password-v2" | docker secret create db_password_v2 -

# Update service to use new secret
docker config create db_config.yml <<EOF
secrets:
  db_password:
    external: true
  db_user:
    external: true
EOF

# Rolling update
docker service update --secret-rm db_password --secret-add source=db_password_v2,target=db_password myservice
```

## Environment Variable Rotation

### For Docker Compose (non-Swarm)

```bash
# 1. Update .env file
# POSTGRES_PASSWORD=new-password-here

# 2. Recreate containers
docker compose down
docker compose up -d
```

### Scripted Rotation

```bash
#!/bin/bash
# rotate-secrets.sh

# Generate new password
NEW_PASSWORD=$(openssl rand -base64 32)

# Update .env
sed -i "s/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$NEW_PASSWORD/" .env

# Restart services
docker compose down
docker compose up -d

echo "Secrets rotated. New password set."
```

## PostgreSQL Password Rotation

```bash
# Connect to PostgreSQL
docker exec -it postgresql-container psql -U docker

# Change password
ALTER USER docker WITH PASSWORD 'new-secure-password';

# Exit
\q
```

## Best Practices

1. **Use Docker Secrets in Swarm mode** - Secrets are encrypted at rest
2. **Rotate regularly** - Every 90 days minimum
3. **Use strong passwords** - 32+ characters, random
4. **Never commit secrets** - Keep .env in .gitignore
5. **Audit access** - Enable audit logging

```bash
# Generate strong password
openssl rand -base64 32

# Or with pwgen
pwgen -s 32 1
```