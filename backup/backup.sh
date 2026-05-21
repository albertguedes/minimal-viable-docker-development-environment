#!/bin/bash
#
# backup.sh - Backup PostgreSQL database
# Usage: ./backup.sh [container_name]
#

set -e
CONTAINER="${1:-postgresql-container}"
BACKUP_DIR="$(dirname "$0")/../backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"

echo "Backing up $CONTAINER..."
docker exec "$CONTAINER" pg_dump -U "${POSTGRES_USER:-docker}" -d "${POSTGRES_DB:-dockerdb}" | gzip > "$BACKUP_DIR/postgresql_${TIMESTAMP}.sql.gz"
echo "Created: $BACKUP_DIR/postgresql_${TIMESTAMP}.sql.gz"

find "$BACKUP_DIR" -name "postgresql_*.sql.gz" -mtime +7 -delete
echo "Old backups (>7 days) cleaned up."