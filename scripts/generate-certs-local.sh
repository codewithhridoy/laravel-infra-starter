#!/bin/bash
set -e

# Resolve script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"

ENV_FILE="$PROJECT_ROOT/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env not found at: $ENV_FILE"
    echo "💡 Hint: Run 'cp .env.example .env' in project root"
    exit 1
fi

# Extract APP_HOST manually
APP_HOST=$(grep -E "^APP_HOST=" "$ENV_FILE" | cut -d '=' -f2- | xargs)

if [ -z "$APP_HOST" ]; then
    echo "❌ APP_HOST is not set in .env"
    echo "💡 Example: APP_HOST=api.auth.abc.localhost.test"
    exit 1
fi

CERTS_DIR="$PROJECT_ROOT/compose/local/traefik/certs"
mkdir -p "$CERTS_DIR"

echo "🔐 Generating cert for: $APP_HOST"
mkcert -cert-file "$CERTS_DIR/app.crt" \
       -key-file "$CERTS_DIR/app.key" \
       "$APP_HOST"

echo "✅ Certs generated at: $CERTS_DIR/"

