# Deployment & Release Guide — Personal Finance Manager v1.0

Dokumen ini berisi panduan produksi untuk men-deploy **Laravel REST API v1** pada *shared hosting* (cPanel / DirectAdmin) serta membangun release **Android APK & AAB** dari Flutter dengan penyimpanan sementara di **Drive D:**.

---

## 1. Deployment Backend Laravel ke Shared Hosting

### 1.1 Struktur Direktori Aman (Public Terpisah)
Jangan meletakkan `.env`, `vendor/`, atau `storage/` di dalam `public_html`. Gunakan tata letak berikut di server:

```text
/home/<cpanel_user>/
├── pfm-backend/                 # Root kode Laravel (private, di luar web root)
│   ├── app/
│   ├── bootstrap/
│   ├── config/
│   ├── database/
│   ├── storage/app/private/     # Penyimpanan privat nota transaksi
│   ├── vendor/
│   └── .env
└── public_html/api/             # Document root subdomain api.domain.com
    ├── .htaccess                # Security headers, HTTPS enforcement & Rewrite
    └── index.php                # Diarahkan ke ../../pfm-backend/
```

Sesuaikan dua baris path di `public_html/api/index.php`:
```php
require __DIR__.'/../../pfm-backend/vendor/autoload.php';
$app = require_once __DIR__.'/../../pfm-backend/bootstrap/app.php';
```

### 1.2 Konfigurasi `.env` & Database MySQL
1. Salin [backend/.env.production.example](../backend/.env.production.example) ke `pfm-backend/.env`.
2. Buat database MySQL/MariaDB + user di cPanel dan isi `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`.
3. Pastikan `APP_ENV=production`, `APP_DEBUG=false`, `APP_URL=https://keuangan.underdevelopment.web.id`, dan jalankan:
   ```bash
   php artisan key:generate --force
   ```

### 1.3 Otomasi Deploy, Migrasi & Izin Direktori
Jalankan script [backend/scripts/deploy-shared-hosting.sh](../backend/scripts/deploy-shared-hosting.sh):
```bash
chmod +x ~/pfm-backend/scripts/deploy-shared-hosting.sh
APP_DIR="$HOME/pfm-backend" ~/pfm-backend/scripts/deploy-shared-hosting.sh
```
Script tersebut secara otomatis menjalankan:
- `composer install --no-dev --optimize-autoloader`
- `php artisan migrate --force`
- `php artisan config:cache`, `route:cache`, dan `view:cache`
- Pengaturan izin direktori `0775` pada `storage/` & `bootstrap/cache/`, serta `0750` pada `storage/app/private/receipts/`.

### 1.4 Konfigurasi HTTPS & Health Check
- Aktifkan **AutoSSL / Let's Encrypt** di cPanel untuk domain API Anda.
- [backend/public/.htaccess](../backend/public/.htaccess) otomatis memblokir akses dotfiles (kecuali `.well-known`), menyetel header keamanan (`X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`), dan mengarahkan trafik non-localhost ke `HTTPS`.
- Verifikasi akhir:
  ```bash
  curl -i https://keuangan.underdevelopment.web.id/api/v1/health
  ```

### 1.5 Jadwal Backup Otomatis (Cron Job)
Gunakan [backend/scripts/backup-mysql.sh](../backend/scripts/backup-mysql.sh) dengan retensi otomatis 30 hari:
```cron
0 2 * * * DB_NAME="your_db" DB_USER="your_user" MYSQL_PWD="your_pass" APP_DIR="$HOME/pfm-backend" BACKUP_DIR="$HOME/pfm-backups" /bin/bash $HOME/pfm-backend/scripts/backup-mysql.sh >> $HOME/pfm-backups/cron.log 2>&1
```

---

## 2. Build Release Android APK & App Bundle (AAB) di Drive D:

### 2.1 Konfigurasi Keystore Produksi
1. Generate keystore (simpan di luar repository):
   ```powershell
   keytool -genkey -v -keystore D:\keys\pfm-release.jks -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 -alias pfm_release_key
   ```
2. Salin [mobile/android/key.properties.example](../mobile/android/key.properties.example) menjadi `mobile/android/key.properties` dan isi path/password keystore tersebut *(file `key.properties` otomatis diabaikan `.gitignore`)*. Jika `key.properties` tidak ada, Gradle menggunakan konfigurasi fallback debug signing agar build lokal tetap berjalan.
3. `AndroidManifest.xml` menonaktifkan backup cloud Android (`android:allowBackup="false"`, `android:fullBackupContent="false"`) untuk melindungi SQLite dan token autentikasi lokal sesuai PRD Section 12.

### 2.2 Perintah Build APK & AAB (Mengisolasi Temp/Cache ke Drive D:)

```powershell
$tempDir = 'd:\kerja\Sistem\personal-finance-manager\temp'
$env:TEMP = $tempDir
$env:TMP = $tempDir
$env:TMPDIR = $tempDir
$env:PUB_CACHE = 'D:\.pub-cache'
$env:GRADLE_USER_HOME = 'D:\.gradle'
$env:ANDROID_USER_HOME = 'D:\.android'
$env:JAVA_TOOL_OPTIONS = '-Djava.io.tmpdir=d:/kerja/Sistem/personal-finance-manager/temp'
$env:PATH = 'D:\flutter\bin;' + $env:PATH

Set-Location 'd:\kerja\Sistem\personal-finance-manager\mobile'
flutter build apk --release --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://keuangan.underdevelopment.web.id/api/v1
flutter build appbundle --release --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://keuangan.underdevelopment.web.id/api/v1
```

Output artefak rilis tersimpan di:
- **APK:** `mobile/build/app/outputs/flutter-apk/app-release.apk`
- **AAB (Google Play Store):** `mobile/build/app/outputs/bundle/release/app-release.aab`

