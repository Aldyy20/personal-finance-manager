# PowerShell script to package backend for shared hosting (2-Folder Architecture)
# Folder 1: keuangan.underdevelopment.web.id (Public Document Root)
# Folder 2: keuangan_core (Private Laravel Backend Core)

[CmdletBinding()]
param (
    [switch]$IncludeVendor = $true,
    [string]$OutputDir = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BackendDir = Resolve-Path "$ScriptDir\.."
$ProjectRoot = Resolve-Path "$BackendDir\.."

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = "$ProjectRoot\dist\hosting"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Personal Finance Manager - cPanel Packaging Tool" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Backend Source : $BackendDir"
Write-Host "Output Target  : $OutputDir"
Write-Host "Include Vendor : $IncludeVendor"
Write-Host ""

$PublicDir = Join-Path $OutputDir "keuangan.underdevelopment.web.id"
$CoreDir   = Join-Path $OutputDir "keuangan_core"

# Ensure target directories exist
New-Item -ItemType Directory -Force -Path $PublicDir | Out-Null
New-Item -ItemType Directory -Force -Path $CoreDir | Out-Null

# -----------------------------------------------------------------------------
# 1. Prepare Public Document Root: keuangan.underdevelopment.web.id
# -----------------------------------------------------------------------------
Write-Host "==> [1/4] Preparing public document root (keuangan.underdevelopment.web.id)..." -ForegroundColor Yellow

# 1.1 index.php pointing to ../keuangan_core
$indexPhpContent = @'
<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__.'/../keuangan_core/storage/framework/maintenance.php')) {
    require $maintenance;
}

// Register the Composer autoloader from keuangan_core...
require __DIR__.'/../keuangan_core/vendor/autoload.php';

// Bootstrap Laravel and handle the request...
/** @var Application $app */
$app = require_once __DIR__.'/../keuangan_core/bootstrap/app.php';

// Explicitly bind the public path to this document root
$app->usePublicPath(__DIR__);

$app->handleRequest(Request::capture());
'@

Set-Content -Path (Join-Path $PublicDir "index.php") -Value $indexPhpContent -Encoding utf8

# 1.2 .htaccess with HTTPS enforcement, Authorization header, and Rewrite
$htaccessContent = @'
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

    # Block hidden dotfiles except .well-known (Let's Encrypt / ACME)
    RewriteCond %{REQUEST_URI} !^/\.well-known/
    RewriteRule "(^|/)\." - [F]

    # Enforce HTTPS in production for non-localhost hosts
    RewriteCond %{HTTPS} !=on
    RewriteCond %{HTTP:X-Forwarded-Proto} !https
    RewriteCond %{HTTP_HOST} !^(localhost|127\.0\.0\.1)(:[0-9]+)?$ [NC]
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

    # Handle Authorization Header for Sanctum Bearer Tokens
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Handle X-XSRF-Token Header
    RewriteCond %{HTTP:x-xsrf-token} .
    RewriteRule .* - [E=HTTP_X_XSRF_TOKEN:%{HTTP:X-XSRF-Token}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
'@

Set-Content -Path (Join-Path $PublicDir ".htaccess") -Value $htaccessContent -Encoding utf8

# 1.3 robots.txt
$robotsContent = @"
User-agent: *
Disallow: /
"@
Set-Content -Path (Join-Path $PublicDir "robots.txt") -Value $robotsContent -Encoding utf8

Write-Host "    [OK] index.php, .htaccess, and robots.txt created in $PublicDir" -ForegroundColor Green

# -----------------------------------------------------------------------------
# 2. Prepare Private Core: keuangan_core
# -----------------------------------------------------------------------------
Write-Host "==> [2/4] Preparing Laravel core (keuangan_core)..." -ForegroundColor Yellow

$coreItems = @('app', 'config', 'database', 'resources', 'routes', 'scripts', 'artisan', 'composer.json', 'composer.lock', '.env.production.example')
foreach ($item in $coreItems) {
    $src = Join-Path $BackendDir $item
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $CoreDir -Recurse -Force
    }
}

# Copy bootstrap folder but omit cached files
$bootstrapSrc = Join-Path $BackendDir "bootstrap"
$bootstrapDest = Join-Path $CoreDir "bootstrap"
New-Item -ItemType Directory -Force -Path (Join-Path $bootstrapDest "cache") | Out-Null
Copy-Item -Path (Join-Path $bootstrapSrc "app.php") -Destination (Join-Path $bootstrapDest "app.php") -Force
Copy-Item -Path (Join-Path $bootstrapSrc "providers.php") -Destination (Join-Path $bootstrapDest "providers.php") -Force -ErrorAction SilentlyContinue
Set-Content -Path (Join-Path (Join-Path $bootstrapDest "cache") ".gitignore") -Value "*`n!.gitignore" -Encoding utf8

# Recreate clean storage structure (no local Windows caches/logs)
$storageFolders = @(
    "app\private\receipts",
    "app\public",
    "framework\cache\data",
    "framework\sessions",
    "framework\views",
    "logs"
)
foreach ($sub in $storageFolders) {
    $targetFolder = Join-Path (Join-Path $CoreDir "storage") $sub
    New-Item -ItemType Directory -Force -Path $targetFolder | Out-Null
    Set-Content -Path (Join-Path $targetFolder ".gitignore") -Value "*`n!.gitignore" -Encoding utf8
}

# Optional vendor copy
if ($IncludeVendor) {
    $vendorSrc = Join-Path $BackendDir "vendor"
    if (Test-Path $vendorSrc) {
        Write-Host "    Copying vendor dependencies (this may take a moment)..." -ForegroundColor Gray
        Copy-Item -Path $vendorSrc -Destination $CoreDir -Recurse -Force
        Write-Host "    [OK] vendor/ included." -ForegroundColor Green
    } else {
        Write-Warning "    vendor folder not found in $BackendDir. Run 'composer install' locally first if you want vendor bundled."
    }
}

Write-Host "    [OK] Core files staged in $CoreDir" -ForegroundColor Green

# -----------------------------------------------------------------------------
# 3. Create ZIP Archives
# -----------------------------------------------------------------------------
Write-Host "==> [3/4] Creating ZIP packages for cPanel File Manager upload..." -ForegroundColor Yellow

Add-Type -AssemblyName System.IO.Compression.FileSystem

$PublicZip = Join-Path $OutputDir "keuangan.underdevelopment.web.id.zip"
$CoreZip   = Join-Path $OutputDir "keuangan_core.zip"

Write-Host "    Compressing $PublicZip ..." -ForegroundColor Gray
if (Test-Path $PublicZip) {
    Add-Type -AssemblyName Microsoft.VisualBasic
    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($PublicZip, 'OnlyErrorDialogs', 'SendToRecycleBin')
}
[System.IO.Compression.ZipFile]::CreateFromDirectory($PublicDir, $PublicZip, [System.IO.Compression.CompressionLevel]::Optimal, $false)

Write-Host "    Compressing $CoreZip ..." -ForegroundColor Gray
if (Test-Path $CoreZip) {
    Add-Type -AssemblyName Microsoft.VisualBasic
    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($CoreZip, 'OnlyErrorDialogs', 'SendToRecycleBin')
}
[System.IO.Compression.ZipFile]::CreateFromDirectory($CoreDir, $CoreZip, [System.IO.Compression.CompressionLevel]::Optimal, $false)

Write-Host "    [OK] Archives ready." -ForegroundColor Green

# -----------------------------------------------------------------------------
# 4. Summary & Verification
# -----------------------------------------------------------------------------
Write-Host "==> [4/4] Package Generation Complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Generated Packages in $OutputDir :" -ForegroundColor White
Get-ChildItem -Path $OutputDir -File | Select-Object Name, @{Name="Size (MB)";Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime | Format-Table -AutoSize

Write-Host "Cara Deploy ke Hosting cPanel:" -ForegroundColor Yellow
Write-Host "1. Buka cPanel > File Manager."
Write-Host "2. Masuk ke folder 'keuangan.underdevelopment.web.id' lalu Upload & Extract 'keuangan.underdevelopment.web.id.zip'."
Write-Host "3. Masuk ke folder 'keuangan_core' lalu Upload & Extract 'keuangan_core.zip'."
Write-Host "4. Di dalam 'keuangan_core', salin file '.env.production.example' menjadi '.env' dan sesuaikan DB_DATABASE, DB_USERNAME, DB_PASSWORD, GEMINI_API_KEY, GROQ_API_KEY."
Write-Host "5. Jalankan migrasi database via Terminal cPanel: 'cd ~/keuangan_core && php artisan migrate --force'."
Write-Host ""

