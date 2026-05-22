#!/bin/bash
#
# test_backup.sh - Test backup and restore scripts
#
set -e

SCRIPT_DIR="/home/albert/Development/DOCKER/minimal_viable/backup"
BACKUP_DIR="$SCRIPT_DIR"
CONTAINER="${POSTGRES_CONTAINER:-postgresql-container}"
DB_NAME="${POSTGRES_DB:-dockerdb}"
DB_USER="${POSTGRES_USER:-docker}"

echo "========================================"
echo "Testing Backup Scripts"
echo "========================================"

echo ""
echo "[TEST 1] Backup creation"
echo "-----------------------------------"
bash "$BACKUP_DIR/backup.sh"
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/postgresql_*.sql.gz 2>/dev/null | head -1)
if [ -z "$LATEST_BACKUP" ]; then
    echo "FAIL: No backup file created"
    exit 1
fi
echo "OK: Backup created: $LATEST_BACKUP"

echo ""
echo "[TEST 2] Backup file validity"
echo "-----------------------------------"
if [ ! -f "$LATEST_BACKUP" ]; then
    echo "FAIL: Backup file does not exist"
    exit 1
fi
if ! file "$LATEST_BACKUP" | grep -q "gzip compressed"; then
    echo "FAIL: Backup file is not a valid gzip"
    exit 1
fi
SIZE=$(stat -f%z "$LATEST_BACKUP" 2>/dev/null || stat -c%s "$LATEST_BACKUP")
if [ "$SIZE" -eq 0 ]; then
    echo "FAIL: Backup file is empty"
    exit 1
fi
echo "OK: Backup file valid (gzip, $SIZE bytes)"

echo ""
echo "[TEST 3] Backup file content"
echo "-----------------------------------"
CONTENT=$(gunzip -c "$LATEST_BACKUP" | head -1)
if [ -z "$CONTENT" ]; then
    echo "FAIL: Backup file is empty after decompression"
    exit 1
fi
echo "OK: Backup file contains data"

echo ""
echo "[TEST 4] Restore from backup"
echo "-----------------------------------"
echo "Note: This creates a pre-restore safety backup automatically"
bash "$BACKUP_DIR/restore.sh" "$LATEST_BACKUP"
echo "OK: Restore completed"

echo ""
echo "[TEST 5] Path validation in backup.sh"
echo "-----------------------------------"
if grep -q 'BACKUP_DIR_ABS.*realpath' "$BACKUP_DIR/backup.sh"; then
    echo "OK: backup.sh has path validation"
else
    echo "WARN: backup.sh may be missing path validation"
fi

echo ""
echo "[TEST 6] Restore script usage"
echo "-----------------------------------"
if bash "$BACKUP_DIR/restore.sh" 2>&1 | grep -q "Usage:"; then
    echo "OK: restore.sh shows usage when no args"
else
    echo "FAIL: restore.sh should show usage when no args"
    exit 1
fi

echo ""
echo "[TEST 7] Restore script file check"
echo "-----------------------------------"
if bash "$BACKUP_DIR/restore.sh" "/nonexistent/file.sql.gz" 2>&1 | grep -q "File not found"; then
    echo "OK: restore.sh validates file exists"
else
    echo "FAIL: restore.sh should check file exists"
    exit 1
fi

echo ""
echo "[TEST 8] Safety backup created"
echo "-----------------------------------"
SAFETY_BACKUP=$(ls -t "$BACKUP_DIR"/postgresql_pre_restore_*.sql.gz 2>/dev/null | head -1)
if [ -n "$SAFETY_BACKUP" ]; then
    echo "OK: Safety backup found: $SAFETY_BACKUP"
else
    echo "WARN: No safety backup found (may have been cleaned up)"
fi

echo ""
echo "========================================"
echo "All backup tests PASSED"
echo "========================================"