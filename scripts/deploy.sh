#!/bin/bash
set -e

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env not found at: $ENV_FILE"
    echo "💡 Hint: Run 'cp .env.example .env' in project root"
    exit 1
fi

# Extract APP_URL and APP_HOST
APP_URL=$(grep -E "^APP_URL=" "$ENV_FILE" | cut -d '=' -f2- | xargs)
APP_HOST=$(grep -E "^APP_HOST=" "$ENV_FILE" | cut -d '=' -f2- | xargs)

if [ -z "$APP_HOST" ]; then
    echo "❌ APP_HOST is not set in .env"
    echo "💡 Example: APP_HOST=api.auth.abc.localhost.test"
    exit 1
fi

ENV=${1:-prod}
OVERLAY="k8s/overlays/$ENV"

if [ ! -d "$PROJECT_ROOT/$OVERLAY" ]; then
    echo "❌ Overlay not found: $OVERLAY"
    exit 1
fi

echo "🚀 Deploying to $ENV with APP_HOST=$APP_HOST..."

# Export for envsubst
export APP_HOST

# Build and apply
cd "$PROJECT_ROOT"
kustomize build "$OVERLAY" | envsubst | kubectl apply -f -

echo "⏳ Waiting 10s for rollout..."
sleep 10

# Optional: Use custom healthcheck path
HEALTHCHECK_PATH=$(grep -E "^HEALTHCHECK_PATH=" "$ENV_FILE" | cut -d '=' -f2- | xargs)
HEALTHCHECK_PATH=${HEALTHCHECK_PATH:-/health}

echo "🧪 Running healthcheck on: https://$APP_HOST$HEALTHCHECK_PATH"
if curl -f -k "https://$APP_HOST$HEALTHCHECK_PATH" > /dev/null 2>&1; then
    echo "✅ Service is healthy!"
else
    echo "❌ Healthcheck failed. Rollback recommended."
    exit 1
fi
