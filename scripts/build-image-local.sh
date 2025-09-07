#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"

echo "🏗️ Building local image..."

# Build base first — NOTE: path is infra/docker/...
docker build -f "$PROJECT_ROOT/infra/docker/base/Dockerfile.base" -t laravel-infra-base:latest .

# Build local dev image
docker build -f "$PROJECT_ROOT/infra/docker/local/Dockerfile.local" -t laravel-app:local-dev .

echo "✅ Local image: laravel-app:local-dev"

