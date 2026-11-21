#!/usr/bin/env bash
set -euo pipefail

# Deployment script for Laravel API on shared hosting (non-public directory layout)
APP_DIR="${APP_DIR:-$HOME/pfm-backend}"
PHP_BIN="${PHP_BIN:-php}"
COMPOSER_BIN="${COMPOSER_BIN:-composer}"

echo "==> Entering backend directory: $APP_DIR"
cd "$APP_DIR"

echo "==> Putting application into maintenance mode (if vendor ready)"
if [ -f vendor/autoload.php ]; then
  "$PHP_BIN" artisan down --retry=60 || true
fi

echo "==> Installing Composer production dependencies"
"$COMPOSER_BIN" install --no-dev --optimize-autoloader --no-interaction

echo "==> Running production database migrations"
"$PHP_BIN" artisan migrate --force

echo "==> Caching config, routes, and views"
"$PHP_BIN" artisan config:cache
"$PHP_BIN" artisan route:cache
"$PHP_BIN" artisan view:cache

echo "==> Hardening writable storage & cache directories (0775)"
mkdir -p storage/app/private/receipts storage/framework/{cache,sessions,views} storage/logs bootstrap/cache
chmod -R 775 storage bootstrap/cache
chmod 750 storage/app/private storage/app/private/receipts

echo "==> Bringing application online"
"$PHP_BIN" artisan up

echo "==> Deployment complete. Verify /api/v1/health endpoint over HTTPS."

