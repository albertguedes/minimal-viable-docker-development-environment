#!/bin/bash
#
# verify-restore.sh - Verify backup integrity by restoring to a test database
#
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.local.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

BACKUP_DIR="$SCRIPT_DIR"
CONTAINER_NAME="mv-pg-restore-test"
DB_NAME="${POSTGRES_DB:-dockerdb}"
DB_USER="${POSTGRES_USER:-docker}"
DB_PASSWORD="${POSTGRES_PASSWORD:-docker}"

LATEST_BACKUP=$(find "$BACKUP_DIR" -name "postgresql_*.sql.gz*" -type f | sort -r | head -1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "ERROR: No backup file found in $BACKUP_DIR"
    exit 1
fi

echo "[$(date)] Found backup: $LATEST_BACKUP"

cleanup() {
    echo "[$(date)] Cleaning up test container..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
}
trap cleanup EXIT

echo "[$(date)] Starting test PostgreSQL container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    -e POSTGRES_DB="$DB_NAME" \
    -e POSTGRES_USER="$DB_USER" \
    -e POSTGRES_PASSWORD="$DB_PASSWORD" \
    -e POSTGRES_PASSWORD="$DB_PASSWORD" \
    postgres:17-alpine

for i in {1..30}; do
    if docker exec "$CONTAINER_NAME" pg_isready -U "$DB_USER" -d "$DB_NAME" 2>/dev/null; then
        echo "[$(date)] Test database is ready"
        break
    fi
    echo "[$(date)] Waiting for database... ($i/30)"
    sleep 2
done

if [[ "$LATEST_BACKUP" == *.gpg ]]; then
    echo "[$(date)] Decrypting backup..."
    DECRYPTED_FILE="${LATEST_BACKUP%.gpg}"
    gpg --batch --yes --decrypt --recipient "$GPG_RECIPIENT" \
        --output "$DECRYPTED_FILE" "$LATEST_BACKUP" 2>/dev/null || \
        gpg --batch --yes --decrypt --output "$DECRYPTED_FILE" "$LATEST_BACKUP"
    RESTORE_FILE="$DECRYPTED_FILE"
else
    RESTORE_FILE="$LATEST_BACKUP"
fi

echo "[$(date)] Restoring backup to test database..."
if gunzip -c "$RESTORE_FILE" | docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" 2>&1; then
    echo "[$(date)] Restore completed successfully"

    RESULT=$(docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM pg_database WHERE datname = '$DB_NAME'" 2>/dev/null)
    RESULT=${RESULT// /}
    RESULT=${RESULT//$'\n'/}

    if [ "$RESULT" -gt 0 ]; then
        echo "[$(date)] VERIFICATION PASSED: Database '$DB_NAME' exists with data"
        EXIT_CODE=0
    else
        echo "[$(date)] VERIFICATION FAILED: Database exists but may be empty"
        EXIT_CODE=1
    fi
else
    echo "[$(date)] VERIFICATION FAILED: Restore command failed"
    EXIT_CODE=1
fi

if [ -f "${DECRYPTED_FILE:-}" ]; then
    rm -f "$DECRYPTED_FILE"
fi

echo "[$(date)] Verification complete. Exit code: $EXIT_CODE"
exit $EXIT_CODE