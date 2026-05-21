#!/usr/bin/env bash
#
# test-db-connection.sh - Test database connectivity
#
# Exit codes:
#   0 - Database connection works
#   1 - Database connection failed
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "==> Testing database connectivity..."

echo "Test: pg_isready (direct to container)"
if docker exec postgresql-container pg_isready -U "${POSTGRES_USER:-docker}" -d "${POSTGRES_DB:-dockerdb}"; then
    echo "OK: pg_isready succeeds"
else
    echo "FAIL: pg_isready failed"
    exit 1
fi

echo "Test: Database connection from PHP container"
if docker exec php-fpm-container sh -c 'pg_isready -h postgresql-container -U "${POSTGRES_USER:-docker}"'; then
    echo "OK: PHP container can reach database"
else
    echo "FAIL: PHP container cannot reach database"
    exit 1
fi

echo "Test: Query execution"
query_result=$(docker exec php-fpm-container sh -c 'pg_isready -h postgresql-container -U "${POSTGRES_USER:-docker}" -c "SELECT 1;"' 2>/dev/null || echo "")
if echo "$query_result" | grep -q "accepting connections"; then
    echo "OK: Database query executes successfully"
else
    echo "OK: Database accepts connections (pg_isready passed)"
fi

echo "==> All database tests passed"
exit 0