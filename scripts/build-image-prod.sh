#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"

echo "🏗️ Building prod image..."

# Build base
docker build -f "$PROJECT_ROOT/docker/base/Dockerfile.base" -t laravel-infra-base:latest .

# Build prod
TAG=sha-$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || echo "latest")
docker build -f "$PROJECT_ROOT/docker/prod/Dockerfile.prod" -t ghcr.io/yourorg/laravel-app:"$TAG" .

echo "✅ Built: ghcr.io/yourorg/laravel-app:$TAG"

# Uncomment to push
# docker push ghcr.io/yourorg/laravel-app:"$TAG"
