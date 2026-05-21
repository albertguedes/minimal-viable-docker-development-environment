#!/usr/bin/env bash
#
# test-healthchecks.sh - Wait for all services to be healthy
#
# Exit codes:
#   0 - All services are healthy
#   1 - Timeout waiting for services
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

SERVICES=("db" "php" "webserver")
TIMEOUT=60
INTERVAL=2

echo "==> Waiting for services to be healthy (timeout: ${TIMEOUT}s)..."

for service in "${SERVICES[@]}"; do
    echo "Checking $service..."
    elapsed=0

    while [ $elapsed -lt $TIMEOUT ]; do
        status=$(docker compose ps "$service" --format json 2>/dev/null | grep -o '"Health":"[^"]*"' | cut -d'"' -f4 || echo "")

        if [ "$status" = "healthy" ]; then
            echo "OK: $service is healthy"
            break
        fi

        if [ $elapsed -ge $TIMEOUT ]; then
            echo "FAIL: $service did not become healthy within ${TIMEOUT}s"
            docker-compose ps "$service"
            exit 1
        fi

        sleep $INTERVAL
        elapsed=$((elapsed + INTERVAL))
    done
done

echo "==> All services are healthy"
exit 0