#!/bin/bash
#
# restore.sh - Restore PostgreSQL database
# Usage: ./restore.sh <backup_file> [container]
#

set -e
BACKUP_FILE="$1"
CONTAINER="${2:-postgresql-container}"

[ -z "$BACKUP_FILE" ] && echo "Usage: $0 <backup_file>" && exit 1
[ ! -f "$BACKUP_FILE" ] && echo "File not found: $BACKUP_FILE" && exit 1

echo "Restoring from $BACKUP_FILE..."
gunzip -c "$BACKUP_FILE" | docker exec -i "$CONTAINER" psql -U "${POSTGRES_USER:-docker}" -d "${POSTGRES_DB:-dockerdb}"
echo "Done."