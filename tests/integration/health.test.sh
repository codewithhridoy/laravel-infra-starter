#!/bin/bash
set -e

echo "Testing /health endpoint..."

if curl -f -k "https://localhost/health" > /dev/null 2>&1; then
    echo "/health is responding"
else
    echo "❌ /health failed"
    exit 1
fi
