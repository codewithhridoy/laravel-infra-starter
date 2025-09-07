#!/bin/bash
set -e

if [ ! -f "../.env" ]; then
    echo "❌ .env not found. Copy .env.example first."
    exit 1
fi

set -a
source ../.env
set +a

APP_HOST=$(echo "$APP_URL" | sed -E 's|https?://||')

mkdir -p compose/local/traefik/certs

echo "Generating cert for: $APP_HOST"
mkcert -cert-file compose/local/traefik/certs/app.crt \
       -key-file compose/local/traefik/certs/app.key \
       "$APP_HOST"

echo "Certs generated at: compose/local/traefik/certs/"
