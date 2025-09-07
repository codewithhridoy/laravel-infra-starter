#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env not found at: $ENV_FILE"
    exit 1
fi

# Extract DB_HOST (optional — if you want dynamic DB host)
DB_HOST=$(grep -E "^DB_HOST=" "$ENV_FILE" | cut -d '=' -f2- | xargs)
DB_HOST=${DB_HOST:-mysql}  # default to 'mysql'

until docker compose -f "$PROJECT_ROOT/compose/local/docker-compose.yml" exec -T mysql mysqladmin ping --host="$DB_HOST" --silent; do
    echo "⏳ Waiting for MySQL..."
    sleep 2
done

REDIS_HOST=$(grep -E "^REDIS_HOST=" "$ENV_FILE" | cut -d '=' -f2- | xargs)
REDIS_HOST=${REDIS_HOST:-redis}

until docker compose -f "$PROJECT_ROOT/compose/local/docker-compose.yml" exec -T redis redis-cli -h "$REDIS_HOST" ping | grep -q PONG; do
    echo "⏳ Waiting for Redis..."
    sleep 2
done

echo "✅ DB & Redis ready."
