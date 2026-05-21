#
# restore.sh - PostgreSQL restore script for Docker
#
# Usage: ./restore.sh <backup_file> [container_name]
# Default container: postgresql-container
#

set -e

BACKUP_FILE="$1"
CONTAINER="${2:-postgresql-container}"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file> [container_name]"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "Restoring backup to $CONTAINER from $BACKUP_FILE..."

gunzip -c "$BACKUP_FILE" | docker exec -i "$CONTAINER" psql -U "${POSTGRES_USER:-docker}" -d "${POSTGRES_DB:-dockerdb}"

echo "Restore complete."