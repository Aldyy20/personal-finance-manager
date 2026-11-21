#!/usr/bin/env bash
set -euo pipefail

# Automated MySQL + Private Receipt Storage backup script with 30-day retention
BACKUP_DIR="${BACKUP_DIR:-$HOME/pfm-backups}"
APP_DIR="${APP_DIR:-$HOME/pfm-backend}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:?Set DB_NAME environment variable}"
DB_USER="${DB_USER:?Set DB_USER environment variable}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

DB_ARCHIVE="$BACKUP_DIR/pfm_db_${TIMESTAMP}.sql.gz"
RECEIPTS_ARCHIVE="$BACKUP_DIR/pfm_receipts_${TIMESTAMP}.tar.gz"

echo "==> Dumping MySQL database [$DB_NAME] with --single-transaction"
mysqldump \
  --single-transaction \
  --routines \
  --triggers \
  --quick \
  --lock-tables=false \
  -h "$DB_HOST" \
  -P "$DB_PORT" \
  -u "$DB_USER" \
  "$DB_NAME" | gzip -9 > "$DB_ARCHIVE"

if [ -d "$APP_DIR/storage/app/private" ]; then
  echo "==> Archiving private receipt uploads"
  tar -czf "$RECEIPTS_ARCHIVE" -C "$APP_DIR/storage/app" private
fi

echo "==> Pruning backups older than ${RETENTION_DAYS} days"
find "$BACKUP_DIR" -type f \( -name "pfm_db_*.sql.gz" -o -name "pfm_receipts_*.tar.gz" \) -mtime "+${RETENTION_DAYS}" -delete

echo "==> Backup finished: $DB_ARCHIVE"

