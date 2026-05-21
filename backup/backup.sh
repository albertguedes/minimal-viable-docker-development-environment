#
# backup.sh - PostgreSQL backup script for Docker
#
# Usage: ./backup.sh [container_name]
# Default container: postgresql-container
#

set -e

CONTAINER="${1:-postgresql-container}"
BACKUP_DIR="$(dirname "$0")/../backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="postgresql_${TIMESTAMP}.sql.gz"

mkdir -p "$BACKUP_DIR"

echo "Starting backup of $CONTAINER..."

docker exec "$CONTAINER" pg_dump -U "${POSTGRES_USER:-docker}" -d "${POSTGRES_DB:-dockerdb}" | gzip > "$BACKUP_DIR/$BACKUP_FILE"

echo "Backup created: $BACKUP_DIR/$BACKUP_FILE"
echo "Backup size: $(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)"

find "$BACKUP_DIR" -name "postgresql_*.sql.gz" -mtime +7 -delete

echo "Backup complete. Old backups (>7 days) cleaned up."