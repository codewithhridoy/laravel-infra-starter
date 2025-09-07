#!/bin/bash
set -e

ENV=${1:-prod}

if [ ! -f "../.env" ]; then
    echo "❌ .env not found. Copy .env.example first."
    exit 1
fi

set -a
source ../.env
set +a

APP_HOST=$(echo "$APP_URL" | sed -E 's|https?://||')
export APP_HOST

OVERLAY="k8s/overlays/$ENV"

if [ ! -d "$OVERLAY" ]; then
    echo "❌ Overlay not found: $OVERLAY"
    exit 1
fi

echo "Deploying to $ENV with APP_HOST=$APP_HOST..."

# Build and apply
kustomize build "$OVERLAY" | envsubst | kubectl apply -f -

echo "Waiting 10s for rollout..."
sleep 10

echo "Running healthcheck..."
if curl -f -k "https://$APP_HOST/health" > /dev/null 2>&1; then
    echo "Service is healthy!"
else
    echo "❌ Healthcheck failed. Rollback recommended."
    exit 1
fi
