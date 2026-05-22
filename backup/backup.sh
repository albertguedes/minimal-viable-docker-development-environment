#!/bin/bash
#
# backup.sh - Backup PostgreSQL database
#
set -e

CONTAINER="${POSTGRES_CONTAINER:-postgresql-container}"
BACKUP_DIR="$(dirname "$0")"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_NAME="${POSTGRES_DB:-dockerdb}"
DB_USER="${POSTGRES_USER:-docker}"

mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting backup of $DB_NAME..."
docker exec "$CONTAINER" pg_dump -h localhost -U "$DB_USER" -d "$DB_NAME" | gzip > "$BACKUP_DIR/postgresql_${TIMESTAMP}.sql.gz"
echo "[$(date)] Backup created: $BACKUP_DIR/postgresql_${TIMESTAMP}.sql.gz ($(du -h "$BACKUP_DIR/postgresql_${TIMESTAMP}.sql.gz" | cut -f1))"

BACKUP_DIR_ABS="$(realpath "$BACKUP_DIR")"
if [[ "$BACKUP_DIR_ABS" != *"/backup" ]]; then
    echo "ERROR: Backup directory must be within a /backup subdirectory"
    exit 1
fi

find "$BACKUP_DIR" -name "postgresql_*.sql.gz" -mtime +7 -delete
echo "[$(date)] Old backups (>7 days) cleaned up"