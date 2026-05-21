# Cloud Deployment Guide

Deploy this project to major cloud providers.

---

## AWS (ECS/Fargate)

### Prerequisites
- AWS CLI configured
- ECS cluster created
- ECR repositories for images

### Build and Push Images

```bash
# Get login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account>.dkr.ecr.us-east-1.amazonaws.com

# Tag images
docker tag nginx-image <account>.dkr.ecr.us-east-1.amazonaws.com/minimal-viable-nginx:latest
docker tag php-fpm-image <account>.dkr.ecr.us-east-1.amazonaws.com/minimal-viable-php:latest
docker tag postgresql-image <account>.dkr.ecr.us-east-1.amazonaws.com/minimal-viable-postgres:latest

# Push images
docker push <account>.dkr.ecr.us-east-1.amazonaws.com/minimal-viable-nginx:latest
docker push <account>.dkr.ecr.us-east-1.amazonaws.com/minimal-viable-php:latest
docker push <account>.dkr.ecr.us-east-1.amazonaws.com/minimal-viable-postgres:latest
```

### ECS Task Definition

```json
{
  "family": "minimal-viable",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "nginx",
      "image": "<account>.dkr.ecr.us-east-1.amazonaws.com/minimal-viable-nginx:latest",
      "portMappings": [{"containerPort": 80}],
      "dependsOn": [{"containerName": "php", "condition": "HEALTHY"}]
    },
    {
      "name": "php",
      "image": "<account>.dkr.ecr.us-east-1.amazonaws.com/minimal-viable-php:latest",
      "portMappings": [{"containerPort": 9000}]
    }
  ]
}
```

### Considerations
- Use AWS RDS for PostgreSQL instead of containerized DB
- Use ElastiCache (Redis) instead of containerized Redis
- Configure ALB for load balancing
- Use EFS for persistent storage

---

## Google Cloud Platform (Cloud Run)

### Prerequisites
- GCP CLI configured
- Project created
- Cloud Run API enabled

### Build and Push to GCR

```bash
# Build and tag
docker build -t gcr.io/<project>/minimal-viable-nginx:latest ./webserver
docker build -t gcr.io/<project>/minimal-viable-php:latest ./php
docker build -t gcr.io/<project>/minimal-viable-postgres:latest ./database

# Push to Container Registry
docker push gcr.io/<project>/minimal-viable-nginx:latest
docker push gcr.io/<project>/minimal-viable-php:latest
docker push gcr.io/<project>/minimal-viable-postgres:latest
```

### Deploy to Cloud Run

```bash
# Deploy services
gcloud run deploy minimal-viable-nginx --image gcr.io/<project>/minimal-viable-nginx:latest --platform managed

# Set environment variables
gcloud run deploy minimal-viable-php --set-envvars POSTGRES_HOST=<db-ip>,POSTGRES_DB=<db>,POSTGRES_USER=<user>
```

### Considerations
- Use Cloud SQL for PostgreSQL
- Use Memorystore for Redis
- Configure Cloud Load Balancing
- Use Secret Manager for credentials

---

## Azure (Container Instances/App Service)

### Prerequisites
- Azure CLI configured
- Resource group created
- Container Registry created

### Build and Push to ACR

```bash
# Login to ACR
az acr login --name <registry>

# Tag and push
docker tag nginx-image <registry>.azurecr.io/minimal-viable-nginx:latest
docker push <registry>.azurecr.io/minimal-viable-nginx:latest
```

### Deploy with Azure Container Instances

```bash
az container create \
  --resource-group <rg> \
  --name minimal-viable-nginx \
  --image <registry>.azurecr.io/minimal-viable-nginx:latest \
  --ports 80 \
  --dns-name-label minimal-viable
```

### Considerations
- Use Azure Database for PostgreSQL
- Use Azure Cache for Redis
- Use Azure Files for persistent storage
- Configure Application Gateway for load balancing

---

## Docker Swarm (Self-Hosted)

### Deploy Stack

```bash
# Initialize Swarm
docker swarm init

# Deploy stack
docker stack deploy -c compose.yaml minimal-viable

# Verify
docker stack ps minimal-viable
```

### Update Services

```bash
# Rebuild images
docker build -t nginx-image ./webserver
docker build -t php-fpm-image ./php

# Update services
docker service update minimal_viable_php --image php-fpm-image
```

### Secrets Management

```bash
# Create secrets
echo "mypassword" | docker secret create db_password -
echo "myuser" | docker secret create db_user -

# Use secrets in compose
secrets:
  db_password:
    external: true
```

---

## Kubernetes

### Manifest Files

Create the following manifests:
- `k8s/postgres-deployment.yaml`
- `k8s/php-deployment.yaml`
- `k8s/nginx-deployment.yaml`
- `k8s/services.yaml`
- `k8s/ingress.yaml`
- `k8s/secrets.yaml`
- `k8s/configmap.yaml`

### Deploy

```bash
kubectl apply -f k8s/
kubectl get pods
kubectl get services
```

---

## Common Considerations

### Environment Variables
Use secrets or configmaps for sensitive data:
- `POSTGRES_PASSWORD`
- Database credentials
- API keys

### Persistence
| Local | Cloud Alternative |
|-------|-------------------|
| `database/data/` | Cloud-managed database |
| `redis-data/` | Managed Redis cache |

### Scaling
- Horizontal scaling: Use load balancer + multiple replicas
- Vertical scaling: Increase CPU/memory limits
- Database: Use connection pooling (PgBouncer)

### Monitoring
- CloudWatch/GCP Monitoring/Azure Monitor
- ELK stack (already included in project)
- Uptime Kuma (already included in project)