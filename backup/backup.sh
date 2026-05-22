#!/bin/bash
#
# backup.sh - Backup PostgreSQL database with encryption and sync
#
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.local.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

CONTAINER="${POSTGRES_CONTAINER:-postgresql-container}"
BACKUP_DIR="$SCRIPT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_NAME="${POSTGRES_DB:-dockerdb}"
DB_USER="${POSTGRES_USER:-docker}"

BACKUP_FILE="$BACKUP_DIR/postgresql_${TIMESTAMP}.sql.gz"
BACKUP_FILE_ENC="$BACKUP_DIR/postgresql_${TIMESTAMP}.sql.gz.gpg"

mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting backup of $DB_NAME..."
docker exec "$CONTAINER" pg_dump -h localhost -U "$DB_USER" -d "$DB_NAME" | gzip > "$BACKUP_FILE"
echo "[$(date)] Backup created: $BACKUP_FILE ($(du -h "$BACKUP_FILE" | cut -f1))"

if [ -n "${GPG_RECIPIENT:-}" ]; then
    echo "[$(date)] Encrypting backup with GPG..."
    gpg --batch --yes --encrypt --recipient "$GPG_RECIPIENT" --output "$BACKUP_FILE_ENC" "$BACKUP_FILE"
    rm -f "$BACKUP_FILE"
    echo "[$(date)] Encrypted backup: $BACKUP_FILE_ENC"
    CURRENT_BACKUP="$BACKUP_FILE_ENC"
else
    CURRENT_BACKUP="$BACKUP_FILE"
fi

if [ -n "${BACKUP_PROVIDER:-}" ] && [ "${BACKUP_PROVIDER}" != "local" ]; then
    case "$BACKUP_PROVIDER" in
        s3)
            if [ -n "${S3_BUCKET:-}" ]; then
                echo "[$(date)] Uploading to S3..."
                aws s3 cp "$CURRENT_BACKUP" "s3://${S3_BUCKET}/$(basename "$CURRENT_BACKUP")"
                echo "[$(date)] Uploaded to S3://${S3_BUCKET}/$(basename "$CURRENT_BACKUP")"
            fi
            ;;
        b2)
            if [ -n "${B2_BUCKET:-}" ]; then
                echo "[$(date)] Uploading to B2..."
                B2_ACCOUNT_ID="${B2_ACCOUNT_ID}" B2_APPLICATION_KEY="${B2_APPLICATION_KEY}" \
                    b2 sync "$CURRENT_BACKUP" "b2://${B2_BUCKET}/"
                echo "[$(date)] Uploaded to B2://${B2_BUCKET}/"
            fi
            ;;
        rsync)
            if [ -n "${RSYNC_DEST:-}" ]; then
                echo "[$(date)] Syncing via rsync..."
                RSYNC_OPTS="-avz --progress"
                [ -n "${RSYNC_SSH_KEY:-}" ] && RSYNC_OPTS="$RSYNC_OPTS -e 'ssh -i $RSYNC_SSH_KEY'"
                rsync $RSYNC_OPTS "$CURRENT_BACKUP" "$RSYNC_DEST/"
                echo "[$(date)] Synced to $RSYNC_DEST"
            fi
            ;;
    esac
fi

find "$BACKUP_DIR" -name "postgresql_*.sql.gz*" -mtime +"${KEEP_LOCAL_DAYS:-7}" -delete 2>/dev/null || true
echo "[$(date)] Old local backups (>$KEEP_LOCAL_DAYS days) cleaned up"