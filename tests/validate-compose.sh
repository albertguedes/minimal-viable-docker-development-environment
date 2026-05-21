#!/usr/bin/env bash
#
# validate-compose.sh - Validate compose.yaml configuration
#
# Exit codes:
#   0 - Configuration is valid
#   1 - Configuration has errors
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "==> Validating compose.yaml..."

if ! docker compose config > /dev/null 2>&1; then
    echo "FAIL: compose.yaml has configuration errors"
    docker compose config
    exit 1
fi

echo "OK: compose.yaml is valid"

echo "==> Checking required files exist..."

REQUIRED_FILES=(
    "database/postgresql.dockerfile"
    "php/php.dockerfile"
    "webserver/nginx.dockerfile"
    "webserver/nginx/default.conf"
    ".env.example"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$PROJECT_ROOT/$file" ]; then
        echo "FAIL: Required file missing: $file"
        exit 1
    fi
    echo "OK: $file exists"
done

if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo "WARN: .env not found. Copy .env.example to .env and configure before running services"
fi

echo "==> All validations passed"
exit 0