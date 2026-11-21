# Testing & Quality Assurance Guide — Personal Finance Manager v1.0

Dokumen ini menjelaskan arsitektur pengujian **Phase 7 — Quality Assurance**, cakupan 12 skenario integrasi [PRD.md](../PRD.md) Section 15.3, serta cara menjalankan pengujian dengan seluruh file sementara pada **Drive D:**.

---

## 1. Pengaturan Lingkungan Drive D: (Anti-Overflow Drive C:)

Sebelum menjalankan PHPUnit maupun Flutter test pada Windows apabila Drive `C:` memiliki ruang terbatas, arahkan seluruh variabel temporer ke Drive `D:`:

```powershell
$env:TEMP = 'd:\kerja\Sistem\personal-finance-manager\temp'
$env:TMP = 'd:\kerja\Sistem\personal-finance-manager\temp'
$env:TMPDIR = 'd:\kerja\Sistem\personal-finance-manager\temp'
$env:PUB_CACHE = 'D:\.pub-cache'
$env:COMPOSER_HOME = 'D:\.composer'
$env:GRADLE_USER_HOME = 'D:\.gradle'
$env:PATH = 'D:\flutter\bin;' + $env:PATH
```

---

## 2. Laravel Backend Test Suite (`backend/tests/`)

| File Pengujian | Fokus Cakupan |
| --- | --- |
| [SchemaAndIntegrityTest.php](../backend/tests/Feature/Database/SchemaAndIntegrityTest.php) | Skema 16 tabel, foreign key komposit lintas pengguna, seeder, imutabilitas ledger & single reversal. |
| [AuthenticationAndDeviceTest.php](../backend/tests/Feature/Api/V1/AuthenticationAndDeviceTest.php) | Registrasi + bootstrap data default, login, refresh token, logout, profil, settings, dan device revocation. |
| [FinancialEngineTest.php](../backend/tests/Feature/Finance/FinancialEngineTest.php) | Opening balance, income, expense (termasuk saldo negatif), transfer, edit reversal, void, adjustment, konflik versi. |
| [AccountsAndCategoriesApiTest.php](../backend/tests/Feature/Api/V1/AccountsAndCategoriesApiTest.php) | CRUD rekening & kategori, arsip/pulihkan, rekonsiliasi saldo, dan isolasi kepemilikan `403`. |
| [TransactionsAndTransfersApiTest.php](../backend/tests/Feature/Api/V1/TransactionsAndTransfersApiTest.php) | Endpoint transaksi/transfer, filter, `409 CONFLICT`, riwayat revisi, serta void. |
| [BudgetsReceiptsAndReportsApiTest.php](../backend/tests/Feature/Api/V1/BudgetsReceiptsAndReportsApiTest.php) | Perhitungan anggaran bulanan, validasi MIME/checksum upload & download nota privat, dan laporan overview/analitik. |
| [SynchronizationApiTest.php](../backend/tests/Feature/Api/V1/SynchronizationApiTest.php) | Idempotensi `/sync/push`, deteksi konflik antar-perangkat, `/sync/pull`, `/sync/status`, dan penolakan perangkat lintas pengguna. |
| [Phase7QualityAssuranceTest.php](../backend/tests/Feature/Qa/Phase7QualityAssuranceTest.php) | Sinkronisasi serentak multi-perangkat, audit keamanan (401, 403 IDOR, revoked device 422, redaksi rahasia), dan performa batch 50 operasi. |

Perintah eksekusi:

```powershell
Set-Location 'd:\kerja\Sistem\personal-finance-manager\backend'
php -d sys_temp_dir="d:/kerja/Sistem/personal-finance-manager/temp" -d upload_tmp_dir="d:/kerja/Sistem/personal-finance-manager/temp" artisan test
```

---

## 3. Flutter Mobile Test Suite (`mobile/test/`)

| File Pengujian | Fokus Cakupan |
| --- | --- |
| [foundation_test.dart](../mobile/test/foundation_test.dart) | Tema Material Design 3 Light/Dark, format Rupiah, kesehatan Drift SQLite + FK pragma, NavigationBar + Dashboard, health API. |
| [offline_persistence_and_sync_test.dart](../mobile/test/offline_persistence_and_sync_test.dart) | Operasi offline lengkap (`accounts`, `income`, `expense`, `transfer`, `edit`, `void`, `budget`, `report`), outbox atomik, dan E2E live sync. |
| [phase6_ui_feature_test.dart](../mobile/test/phase6_ui_feature_test.dart) | Parser OCR Indonesia, rendering UI Dashboard, navigasi adaptif `NavigationBar` <-> `NavigationRail`, form rekening & adjustment, edit/void transaksi, konfirmasi OCR + nota, anggaran, & ekspor CSV. |
| [phase7_qa_integration_test.dart](../mobile/test/phase7_qa_integration_test.dart) | Resiliensi offline & retry saat server mati, preservasi mutasi lokal saat konflik pull, isolasi ganti akun pengguna, persistensi database SQLite fisik Drive `D:` saat restart + benchmark 50 transaksi, serta E2E multi-device live sync & conflict detection. |

Perintah eksekusi penuh (termasuk E2E live sync terhadap Laravel API lokal di port `8000`):

```powershell
Set-Location 'd:\kerja\Sistem\personal-finance-manager\mobile'
flutter analyze
flutter test --dart-define=RUN_LIVE_API_TEST=true --reporter expanded
```

---

## 4. Pemetaan 12 Skenario Integrasi PRD Section 15.3

1. **Create account offline & sync** — `offline_persistence_and_sync_test.dart`, `phase7_qa_integration_test.dart`
2. **Create income offline & sync** — `offline_persistence_and_sync_test.dart`, `phase7_qa_integration_test.dart`
3. **Create expense offline & sync** — `offline_persistence_and_sync_test.dart`, `phase7_qa_integration_test.dart`
4. **Create transfer offline & sync** — `offline_persistence_and_sync_test.dart`, `phase7_qa_integration_test.dart`
5. **Edit transaction on one device** — `SynchronizationApiTest.php`, `phase7_qa_integration_test.dart`
6. **Synchronize changes to another device** — `SynchronizationApiTest.php`, `Phase7QualityAssuranceTest.php`, `phase7_qa_integration_test.dart`
7. **Duplicate push request (idempotency)** — `SynchronizationApiTest.php`, `Phase7QualityAssuranceTest.php`
8. **Simultaneous creation on multiple devices** — `Phase7QualityAssuranceTest.php`, `phase7_qa_integration_test.dart`
9. **Server unavailable during push** — `phase7_qa_integration_test.dart`
10. **Receipt upload interrupted / offline retry** — `BudgetsReceiptsAndReportsApiTest.php`, `phase7_qa_integration_test.dart`
11. **Application restart with pending operations** — `phase7_qa_integration_test.dart` (file SQLite Drive `D:`)
12. **Login with different user on same device** — `phase7_qa_integration_test.dart`

