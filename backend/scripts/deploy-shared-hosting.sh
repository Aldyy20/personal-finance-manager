#!/usr/bin/env bash
set -euo pipefail

# Deployment script for Laravel API on shared hosting with 2-folder structure:
# - Core backend: ~/keuangan_core/
# - Public web root: ~/keuangan.underdevelopment.web.id/

if [ -z "${APP_DIR:-}" ]; then
  if [ -d "$HOME/keuangan_core" ]; then
    APP_DIR="$HOME/keuangan_core"
  elif [ -d "$HOME/pfm-backend" ]; then
    APP_DIR="$HOME/pfm-backend"
  else
    APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  fi
fi

PHP_BIN="${PHP_BIN:-php}"
COMPOSER_BIN="${COMPOSER_BIN:-composer}"

echo "==> Entering backend core directory: $APP_DIR"
cd "$APP_DIR"

echo "==> Putting application into maintenance mode (if vendor ready)"
if [ -f vendor/autoload.php ]; then
  "$PHP_BIN" artisan down --retry=60 || true
fi

echo "==> Installing Composer production dependencies"
if [ -f "$COMPOSER_BIN" ] || command -v "$COMPOSER_BIN" >/dev/null 2>&1; then
  "$COMPOSER_BIN" install --no-dev --optimize-autoloader --no-interaction
else
  echo "Composer binary not found directly, skipping composer install (assuming pre-packaged vendor)."
fi

echo "==> Running production database migrations"
"$PHP_BIN" artisan migrate --force

echo "==> Caching config, routes, and views"
"$PHP_BIN" artisan config:cache
"$PHP_BIN" artisan route:cache
"$PHP_BIN" artisan view:cache

echo "==> Hardening writable storage & cache directories (0775 / 0750)"
mkdir -p storage/app/private/receipts storage/framework/{cache,sessions,views} storage/logs bootstrap/cache
chmod -R 775 storage bootstrap/cache
chmod 750 storage/app/private storage/app/private/receipts

echo "==> Bringing application online"
"$PHP_BIN" artisan up

echo "==> Deployment complete. Verify /api/v1/health endpoint over HTTPS:"
echo "    curl -i https://keuangan.underdevelopment.web.id/api/v1/health"
