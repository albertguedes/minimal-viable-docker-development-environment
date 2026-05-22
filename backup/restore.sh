#!/bin/bash
#
# restore.sh - Restore PostgreSQL database
# Usage: ./restore.sh <backup_file>
#
set -e

BACKUP_FILE="$1"
CONTAINER="${POSTGRES_CONTAINER:-mv-postgresql-container}"
DB_NAME="${POSTGRES_DB:-dockerdb}"
DB_USER="${POSTGRES_USER:-docker}"
BACKUP_DIR="$(dirname "$0")"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SAFETY_BACKUP="$BACKUP_DIR/postgresql_pre_restore_${TIMESTAMP}.sql.gz"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "File not found: $BACKUP_FILE"
    exit 1
fi

BACKUP_FILE_ABS="$(realpath "$BACKUP_FILE")"
if [[ "$BACKUP_FILE_ABS" != *"/backup/"* ]] && [[ "$BACKUP_FILE_ABS" != */backup ]]; then
    echo "ERROR: Backup file must be within a /backup subdirectory"
    exit 1
fi

echo "[$(date)] Creating safety backup before restore..."
docker exec "$CONTAINER" pg_dump -h localhost -U "$DB_USER" -d "$DB_NAME" | gzip > "$SAFETY_BACKUP"
echo "[$(date)] Safety backup created: $SAFETY_BACKUP"

echo "[$(date)] Restoring from $BACKUP_FILE..."
gunzip -c "$BACKUP_FILE" | docker exec -i "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME"
echo "[$(date)] Restore complete"