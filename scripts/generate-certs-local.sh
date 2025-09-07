#!/bin/bash
set -e

if [ ! -f "../.env" ]; then
    echo ".env not found. Copy .env.example first."
    exit 1
fi

set -a
source ../.env
set +a

# Use APP_HOST directly — no parsing needed
echo "Generating cert for: $APP_HOST"
mkcert -cert-file compose/local/traefik/certs/app.crt \
       -key-file compose/local/traefik/certs/app.key \
       "$APP_HOST"

echo "Certs generated at: compose/local/traefik/certs/"