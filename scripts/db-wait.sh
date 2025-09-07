#!/bin/bash
set -e

until docker compose -f compose/local/docker-compose.yml exec -T mysql mysqladmin ping --host=mysql --silent; do
    echo "Waiting for MySQL..."
    sleep 2
done

until docker compose -f compose/local/docker-compose.yml exec -T redis redis-cli ping | grep -q PONG; do
    echo "Waiting for Redis..."
    sleep 2
done

echo "DB & Redis ready."
