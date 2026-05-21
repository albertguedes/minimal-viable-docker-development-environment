#!/usr/bin/env bash
#
# test-http-endpoints.sh - Test HTTP endpoints
#
# Exit codes:
#   0 - All endpoints respond correctly
#   1 - One or more endpoints failed
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

BASE_URL="http://localhost:8080"
FAILED=0

echo "==> Testing HTTP endpoints..."

echo "Test: GET / (index.html)"
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/")
if [ "$response" = "200" ]; then
    echo "OK: / returns HTTP $response"
else
    echo "FAIL: / returns HTTP $response (expected 200)"
    FAILED=1
fi

echo "Test: GET /index.php"
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/index.php")
if [ "$response" = "200" ]; then
    echo "OK: /index.php returns HTTP $response"

    body=$(curl -s "$BASE_URL/index.php")
    if echo "$body" | grep -q "PHP Version"; then
        echo "OK: /index.php returns PHP info page"
    else
        echo "FAIL: /index.php does not contain expected PHP info"
        FAILED=1
    fi
else
    echo "FAIL: /index.php returns HTTP $response (expected 200)"
    FAILED=1
fi

echo "Test: GET /database.php"
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/database.php")
if [ "$response" = "200" ]; then
    echo "OK: /database.php returns HTTP $response"

    body=$(curl -s "$BASE_URL/database.php")
    if echo "$body" | grep -q "Connected to"; then
        echo "OK: /database.php shows successful connection"
    else
        echo "FAIL: /database.php does not show successful connection"
        echo "Response: $body"
        FAILED=1
    fi
else
    echo "FAIL: /database.php returns HTTP $response (expected 200)"
    FAILED=1
fi

if [ $FAILED -eq 1 ]; then
    echo "==> Some tests failed"
    exit 1
fi

echo "==> All HTTP endpoint tests passed"
exit 0