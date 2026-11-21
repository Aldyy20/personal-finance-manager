# Personal Finance Manager v1.0

Aplikasi manajemen keuangan pribadi multi-pengguna berbasis Android **Offline-First**, dibangun menggunakan **Flutter (Material Design 3 + Drift SQLite + Riverpod)**, **Laravel REST API v1 (Sanctum)**, dan **MySQL / MariaDB** dengan mesin akuntansi **immutable ledger**.

---

## Arsitektur & Prinsip Inti
- **Offline-First & Local-First:** Pencatatan transaksi, transfer, manajemen rekening, anggaran, OCR struk, dan laporan berjalan penuh di SQLite lokal tanpa internet dan mencatat antrean sinkronisasi pada `SyncOutbox`.
- **Immutable Ledger & Balance Reconciliation:** Saldo rekening selalu hasil penjumlahan buku besar (`SUM(account_movements.amount_signed)`). Pengeditan dan pembatalan (*void*) transaksi menggunakan mekanisme *reversal + replacement* serta jejak audit `transaction_revisions`.
- **Multi-Device Bidirectional Sync:** `POST /api/v1/sync/push` yang idempotent (`operation_id`) dan `GET /api/v1/sync/pull` berbasis sequence cursor per pengguna, dengan deteksi konflik versi (`CONFLICT`).
- **Material Design 3 Editorial UI:** Mendukung tema Terang/Gelap/Sistem, layout adaptif (`NavigationBar` `< 840dp` / `NavigationRail` `>= 840dp`), format Rupiah `tabular-nums`, dan pemindai/konfirmasi struk OCR.

---

## Struktur Proyek
```text
personal-finance-manager/
├── backend/        # Laravel 12 REST API v1, 16-table MySQL schema & Services
├── mobile/         # Flutter Android app, 14-table Drift SQLite & M3 UI
├── docs/           # Dokumentasi arsitektur, API, DB, sync, QA & deployment
└── PRD.md          # Master Product Requirements Document v1.0
```

## Indeks Dokumentasi (`docs/`)
1. [PRD.md](docs/PRD.md) & [PRD Master Root](PRD.md) — Spesifikasi produk otoritatif.
2. [ARCHITECTURE.md](docs/ARCHITECTURE.md) — Arsitektur end-to-end Offline-First.
3. [IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md) — Rencana pengembangan bertahap Phase 1–8.
4. [ERD.md](docs/ERD.md) — Diagram ERD 16 tabel server & pemetaan 14 tabel Drift lokal.
5. [DATABASE_SPEC.md](docs/DATABASE_SPEC.md) — Skema kolom, tipe data, indeks & constraint.
6. [API_SPEC.md](docs/API_SPEC.md) — Kontrak endpoint REST API v1 & format respons.
7. [SYNC_SPEC.md](docs/SYNC_SPEC.md) — Spesifikasi push outbox, cursor pull & resolusi konflik.
8. [BUSINESS_RULES.md](docs/BUSINESS_RULES.md) — 12 aturan finansial prioritas tertinggi & imutabilitas ledger.
9. [UI_UX_SPEC.md](docs/UI_UX_SPEC.md) — Design system *Editorial Precision Ledger* (M3).
10. [TESTING.md](docs/TESTING.md) — Panduan & skenario QA (Backend PHPUnit + Flutter Unit/Widget/E2E).
11. [DEPLOYMENT.md](docs/DEPLOYMENT.md) — Panduan deploy shared hosting (HTTPS/Backup) & build Android APK/AAB.

---

## Verifikasi Cepat (Drive D:)

```powershell
# Backend PHPUnit
Set-Location 'd:\kerja\Sistem\personal-finance-manager\backend'
php -d sys_temp_dir="d:/kerja/Sistem/personal-finance-manager/temp" artisan test

# Flutter Analyze & Full Test Suite
Set-Location 'd:\kerja\Sistem\personal-finance-manager\mobile'
D:\flutter\bin\flutter.bat analyze
D:\flutter\bin\flutter.bat test --dart-define=RUN_LIVE_API_TEST=true --reporter expanded
```

