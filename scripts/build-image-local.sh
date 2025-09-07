#!/bin/bash
set -e

echo "Building local image..."

# Build base first
docker build -f docker/base/Dockerfile.base -t laravel-infra-base:latest .

# Build local dev image
docker build -f docker/local/Dockerfile.local -t laravel-app:local-dev .

echo "Local image: laravel-app:local-dev"
