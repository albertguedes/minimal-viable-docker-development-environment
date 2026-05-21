#!/bin/bash
#
# restore.sh - Restore PostgreSQL database
# Usage: ./restore.sh <backup_file>
#
set -e

BACKUP_FILE="$1"
CONTAINER="${POSTGRES_CONTAINER:-postgresql-container}"
DB_NAME="${POSTGRES_DB:-dockerdb}"
DB_USER="${POSTGRES_USER:-docker}"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "File not found: $BACKUP_FILE"
    exit 1
fi

echo "[$(date)] Restoring from $BACKUP_FILE..."
gunzip -c "$BACKUP_FILE" | docker exec -i "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME"
echo "[$(date)] Restore complete"