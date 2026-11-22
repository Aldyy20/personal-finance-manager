# Deployment & Release Guide — Personal Finance Manager v1.0

Dokumen ini berisi panduan produksi untuk men-deploy **Laravel REST API v1** pada *shared hosting* (cPanel / DirectAdmin) menggunakan **arsitektur 2-folder terpisah** (`keuangan_core` & `keuangan.underdevelopment.web.id`) serta membangun release **Android APK & AAB** dari Flutter dengan penyimpanan sementara di **Drive D:**.

---

## 1. Arsitektur 2-Folder Hosting (cPanel File Manager)

### 1.1 Struktur Direktori Server
Untuk menjaga keamanan data privat, kredensial `.env`, dan nota transaksi, backend dipisahkan menjadi dua folder berdampingan:

```text
/home/<cpanel_user>/
├── keuangan_core/                                 # [0755] Root backend Laravel (private, di luar web root)
│   ├── app/
│   ├── bootstrap/
│   │   ├── app.php
│   │   └── cache/                                 # [0775] writable cache
│   ├── config/
│   ├── database/
│   ├── resources/
│   ├── routes/
│   ├── scripts/
│   │   ├── deploy-shared-hosting.sh
│   │   └── backup-mysql.sh
│   ├── storage/                                   # [0775] writable storage
│   │   ├── app/private/receipts/                  # [0750] nota belanja privat
│   │   └── framework/{cache,sessions,views}/
│   ├── vendor/                                    # Composer dependencies
│   ├── artisan
│   ├── composer.json
│   ├── composer.lock
│   └── .env                                       # [0600] Kredensial produksi
│
└── keuangan.underdevelopment.web.id/              # [0750] Document root publik subdomain
    ├── .htaccess                                  # Rewriting, Authorization header & HTTPS
    ├── index.php                                  # Front controller mengarah ke ../keuangan_core/
    └── robots.txt                                 # Disallow all bot indexing
```

---

### 1.2 Isi File Publik di `keuangan.underdevelopment.web.id/`

#### File: `index.php`
```php
<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Cek status maintenance di keuangan_core
if (file_exists($maintenance = __DIR__.'/../keuangan_core/storage/framework/maintenance.php')) {
    require $maintenance;
}

// Autoloader Composer dari folder privat keuangan_core
require __DIR__.'/../keuangan_core/vendor/autoload.php';

// Inisialisasi bootstrap Laravel
/** @var Application $app */
$app = require_once __DIR__.'/../keuangan_core/bootstrap/app.php';

// Kaitkan public path ke document root subdomain ini
$app->usePublicPath(__DIR__);

$app->handleRequest(Request::capture());
```

#### File: `.htaccess`
Memastikan URL routing bekerja, header `Authorization: Bearer <token>` diteruskan ke Laravel Sanctum, dan koneksi selalu diarahkan ke HTTPS:
```apache
<IfModule mod_headers.c>
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "DENY"
    Header always set Referrer-Policy "no-referrer"
    Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
</IfModule>

<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Blokir akses hidden files kecuali .well-known (SSL ACME)
    RewriteCond %{REQUEST_URI} !^/\.well-known/
    RewriteRule "(^|/)\." - [F]

    # Paksa HTTPS untuk produksi
    RewriteCond %{HTTPS} !=on
    RewriteCond %{HTTP:X-Forwarded-Proto} !https
    RewriteCond %{HTTP_HOST} !^(localhost|127\.0\.0\.1)(:[0-9]+)?$ [NC]
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

    # Teruskan Authorization Header ke Laravel Sanctum
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Teruskan X-XSRF-Token Header
    RewriteCond %{HTTP:x-xsrf-token} .
    RewriteRule .* - [E=HTTP_X_XSRF_TOKEN:%{HTTP:X-XSRF-Token}]

    # Redirect Trailing Slashes Jika Bukan Direktori Fisik
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Kirim semua request API ke Front Controller index.php
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
```

---

### 1.3 Otomasi Pembuatan Paket Upload (PowerShell)
Untuk mempermudah upload ke cPanel tanpa repot memilah file manual atau menjalankan Composer di server:

1. Jalankan script packaging di terminal Windows:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "d:\kerja\Sistem\personal-finance-manager\backend\scripts\package-cpanel.ps1"
   ```
2. Script ini secara otomatis menghasilkan 2 paket ZIP siap upload di `dist/hosting/`:
   - `keuangan.underdevelopment.web.id.zip` (berisi `index.php`, `.htaccess`, `robots.txt`)
   - `keuangan_core.zip` (berisi seluruh kode Laravel + `vendor` produksi + struktur `storage` bersih)

---

### 1.4 Langkah Deploy di cPanel File Manager

1. **Upload ke Document Root Subdomain:**
   - Buka cPanel > **File Manager**.
   - Masuk ke folder `keuangan.underdevelopment.web.id/`.
   - Unggah `keuangan.underdevelopment.web.id.zip` lalu klik kanan > **Extract**.
   - Hapus file `.zip` setelah diekstrak.

2. **Upload ke Core Backend:**
   - Masuk ke folder `keuangan_core/`.
   - Unggah `keuangan_core.zip` lalu klik kanan > **Extract**.
   - Hapus file `.zip` setelah diekstrak.

3. **Konfigurasi File `.env` di `keuangan_core/`:**
   - Ubah nama `.env.production.example` menjadi `.env` (atau edit file `.env` yang ada).
   - Pastikan konfigurasi database diisi sesuai database cPanel Anda:
     ```dotenv
     APP_NAME="Personal Finance Manager API"
     APP_ENV=production
     APP_KEY=base64:... (generate dengan php artisan key:generate)
     APP_DEBUG=false
     APP_URL=https://keuangan.underdevelopment.web.id

     DB_CONNECTION=mysql
     DB_HOST=127.0.0.1
     DB_PORT=3306
     DB_DATABASE=nama_cpanel_db
     DB_USERNAME=nama_cpanel_user
     DB_PASSWORD="password_database_anda"

     GEMINI_API_KEY=kunci_gemini_anda
     GEMINI_MODEL=gemini-flash-lite-latest
     GROQ_API_KEY=kunci_groq_anda
     GROQ_VISION_MODEL=qwen/qwen3.8-27b
     ```

4. **Jalankan Migrasi Database:**
   - Jika cPanel memiliki menu **Terminal**:
     ```bash
     cd ~/keuangan_core
     php artisan migrate --force
     php artisan config:cache
     php artisan route:cache
     ```
   - Atau jalankan script:
     ```bash
     bash ~/keuangan_core/scripts/deploy-shared-hosting.sh
     ```

---

### 1.5 Mengatasi Imunify360 / Bot Protection pada Subdomain API

Jika permintaan aplikasi mobile atau endpoint API menghasilkan pesan:
> `"Access denied by Imunify360 bot-protection. IPs used for automation should be whitelisted"`

Hal ini terjadi karena fitur **WebShield / Bot Protection** dari Imunify360 di hosting mendeteksi request API non-browser dan meminta verifikasi JavaScript. Cara mengatasinya:

1. **Whitelisting di cPanel Imunify360 (Jika Tersedia):**
   - Buka cPanel > **Imunify360**.
   - Di tab Incidents / White List, tambahkan domain `keuangan.underdevelopment.web.id` atau nonaktifkan WebShield untuk subdomain ini.
2. **Matikan ModSecurity untuk Subdomain (Jika Diizinkan Host):**
   - Buka cPanel > **Security** > **ModSecurity**.
   - Cari domain `keuangan.underdevelopment.web.id` dan ubah statusnya menjadi **Off / Disable**.
3. **Hubungi Support Hosting (Tiket Bantuan):**
   - Kirimkan tiket ke penyedia hosting dengan template berikut:
     > *"Halo Tim Support, mohon bantuan untuk menonaktifkan fitur Imunify360 Bot-Protection / WebShield atau menambahkan whitelist pada subdomain `keuangan.underdevelopment.web.id`. Subdomain ini digunakan secara khusus sebagai endpoint REST API untuk aplikasi mobile Android kami (Personal Finance Manager) sehingga request dari aplikasi mobile tidak boleh dicegat oleh JavaScript challenge bot-protection. Terima kasih."*
4. **Proteksi di Sisi Aplikasi Mobile:**
   - Aplikasi mobile kini telah dilengkapi header `User-Agent: PersonalFinanceApp/1.0.0 (Android; Mobile)` dan pemetaan pesan error bahasa Indonesia yang jelas jika proteksi hosting memblokir koneksi.

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
