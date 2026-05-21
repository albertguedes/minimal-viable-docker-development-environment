#!/bin/bash
#
# migrate.sh - Database migration runner
#
# Usage: ./migrate.sh [up|down|status]
#

set -e

HOST="${POSTGRES_HOST:-postgresql-container}"
PORT="${POSTGRES_PORT:-5432}"
USER="${POSTGRES_USER:-docker}"
DB="${POSTGRES_DB:-dockerdb}"
MIGRATIONS_DIR="$(dirname "$0")/../migrations"

PSQL="docker exec postgresql-container psql -U $USER -d $DB"

usage() {
    echo "Usage: $0 [up|down|status]"
    exit 1
}

migrate_up() {
    echo "Running migrations..."
    for migration in $(ls -1 "$MIGRATIONS_DIR"/*.sql | sort); do
        echo "Applying: $(basename $migration)"
        docker exec -i postgresql-container psql -U "$USER" -d "$DB" < "$migration"
    done
    echo "Migrations complete."
}

migrate_status() {
    echo "Migration status:"
    $PSQL -c "SELECT version, applied_at FROM migrations ORDER BY applied_at;"
}

case "${1:-up}" in
    up) migrate_up ;;
    status) migrate_status ;;
    *) usage ;;
esac