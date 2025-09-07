#!/bin/bash
set -e

echo "Building prod image..."

# Build base
docker build -f docker/base/Dockerfile.base -t laravel-infra-base:latest .

# Build prod
TAG=sha-$(git rev-parse --short HEAD 2>/dev/null || echo "latest")
docker build -f docker/prod/Dockerfile.prod -t ghcr.io/yourorg/laravel-app:"$TAG" .

echo "Built: ghcr.io/yourorg/laravel-app:$TAG"

# Uncomment to push
# docker push ghcr.io/yourorg/laravel-app:"$TAG"
