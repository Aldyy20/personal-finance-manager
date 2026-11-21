# MASTER PRODUCT REQUIREMENTS DOCUMENT (PRD)

# PERSONAL FINANCE MANAGER

**Document Version:** 1.0  
**Document Type:** Master PRD + Software Requirements Specification + Technical Specification  
**Project Status:** Approved for Development Planning  
**Platform:** Android  
**Frontend:** Flutter / Dart  
**Backend:** PHP / Laravel  
**Server Database:** MySQL 8.0.16+  
**Local Database:** SQLite / Drift  
**Architecture:** Offline-First Client-Server  
**UI Design System:** Material Design 3  
**Currency:** Indonesian Rupiah (IDR)

---

# 1. PROJECT OVERVIEW

## 1.1 Product Description

Personal Finance Manager adalah aplikasi Android untuk mengelola keuangan pribadi secara terstruktur, terintegrasi, dan mudah digunakan.

Aplikasi memungkinkan pengguna mencatat pemasukan, pengeluaran, dan transfer antar-sumber dana. Pengguna dapat mengelola berbagai rekening bank, uang tunai, serta dompet digital dalam satu aplikasi.

Aplikasi juga menyediakan pengelolaan kategori transaksi, budgeting, laporan keuangan, dan pemindaian nota menggunakan Optical Character Recognition (OCR).

Sistem menggunakan pendekatan Offline-First sehingga seluruh aktivitas utama tetap dapat dilakukan tanpa koneksi internet. Data disimpan terlebih dahulu pada database lokal perangkat dan disinkronisasikan dengan server ketika koneksi tersedia.

Backend menggunakan Laravel dan database MySQL yang di-hosting pada shared hosting. Aplikasi Android dikembangkan menggunakan Flutter dengan Material Design 3.

## 1.2 Product Vision

Menjadi aplikasi pengelolaan keuangan pribadi yang membantu pengguna mengetahui kondisi keuangan secara menyeluruh, mengontrol pengeluaran, serta mempermudah pencatatan transaksi dari berbagai sumber dana.

## 1.3 Product Objectives

1. Menyediakan pencatatan pemasukan dan pengeluaran yang mudah.
2. Mengelola banyak rekening dan sumber dana.
3. Menampilkan total aset dan saldo setiap rekening secara akurat.
4. Menyediakan transfer antar-rekening.
5. Menyediakan kategori transaksi yang dapat dikustomisasi.
6. Membantu pengendalian pengeluaran melalui budgeting.
7. Mengotomatisasi sebagian pencatatan melalui OCR nota.
8. Menyediakan laporan keuangan yang informatif.
9. Mendukung penggunaan offline.
10. Menyinkronisasikan data ant perangkat secara konsisten.
11. Menjaga privasi dan isolasi data masing-masing pengguna.

## 1.4 Target Users

Aplikasi ditujukan untuk pengguna individu yang ingin mengelola keuangan pribadi.

Target pengguna:

- Mahasiswa.
- Pekerja.
- Freelancer.
- Individu dengan beberapa rekening bank.
- Pengguna dompet digital.
- Individu yang ingin mengontrol pengeluaran bulanan.

## 1.5 Product Scope

Aplikasi merupakan sistem pengelolaan keuangan pribadi.

Setiap pengguna mempunyai akun dan ruang data sendiri.

Satu akun dapat digunakan pada beberapa perangkat Android. Namun, versi pertama tidak menyediakan fitur berbagi rekening, pengelolaan keuangan keluarga, atau kolaborasi antar-pengguna.

---

# 2. FIXED TECHNOLOGY STACK

Teknologi berikut menjadi standar proyek dan tidak boleh diganti tanpa persetujuan pemilik proyek.

| Component                  | Technology                        |
| -------------------------- | --------------------------------- |
| Mobile Framework           | Flutter                           |
| Programming Language       | Dart                              |
| UI System                  | Material Design 3                 |
| State Management           | Riverpod                          |
| Navigation                 | GoRouter                          |
| Local Database             | SQLite                            |
| Local Database ORM         | Drift                             |
| HTTP Client                | Dio                               |
| Backend Framework          | Laravel                           |
| Backend Language           | PHP                               |
| Authentication             | Laravel Sanctum                   |
| Server Database            | MySQL                             |
| OCR                        | Google ML Kit Text Recognition    |
| Image Processing           | Flutter image processing packages |
| Charts                     | fl_chart                          |
| Secure Storage             | Flutter Secure Storage            |
| Background Synchronization | Android WorkManager integration   |
| Hosting                    | Shared Hosting                    |
| API Protocol               | REST API / JSON                   |
| API Security               | HTTPS                             |

## 2.1 Deployment Architecture

Backend, MySQL, dan file storage ditempatkan pada shared hosting.

Flutter dikompilasi menjadi APK atau Android App Bundle.

Tidak diperlukan VPS khusus untuk versi pertama.

Persyaratan hosting:

- Mendukung versi PHP yang kompatibel dengan versi Laravel.
- Mendukung Composer atau deployment vendor dependencies.
- MySQL 8.0.16+ atau versi kompatibel dengan constraint yang digunakan.
- PHP extensions sesuai kebutuhan Laravel.
- SSL/HTTPS.
- File storage dengan permission yang benar.
- Mendukung Laravel scheduler atau cron job jika diperlukan.
- Mendukung mekanisme background processing yang sesuai dengan batasan hosting.

Sistem tidak boleh bergantung pada proses daemon permanen yang tidak didukung shared hosting.

---

# 3. SYSTEM ARCHITECTURE

## 3.1 Architectural Pattern

Gunakan Client-Server Architecture dengan Offline-First Data Strategy.

Flutter menjadi client yang memiliki database lokal sendiri.

Laravel menjadi server pusat yang bertanggung jawab atas autentikasi, validasi, integritas transaksi, penyimpanan permanen, dan sinkronisasi.

## 3.2 Architecture Components

### Mobile Application

Terdiri dari:

1. Presentation Layer
   - Screens.
   - Widgets.
   - Theme.
   - Navigation.

2. Application Layer
   - Use Cases.
   - State Management.
   - Business Workflow.

3. Domain Layer
   - Entities.
   - Repository Contracts.
   - Business Rules.

4. Data Layer
   - SQLite / Drift.
   - Remote API.
   - Repository Implementations.
   - Sync Manager.

5. Device Services
   - Camera.
   - OCR.
   - Local File Storage.
   - Secure Storage.
   - Connectivity Monitoring.

### Backend Application

Terdiri dari:

1. API Layer
   - Routes.
   - Controllers.
   - Middleware.
   - Form Requests.
   - API Resources.

2. Application / Service Layer
   - Account Service.
   - Transaction Service.
   - Transfer Service.
   - Budget Service.
   - Receipt Service.
   - Synchronization Service.

3. Domain Layer
   - Business Rules.
   - Ledger Rules.
   - Validation Rules.

4. Data Layer
   - Eloquent Models.
   - Database Transactions.
   - Repositories jika diperlukan.

## 3.3 Main Architecture Flow

Flutter UI → Riverpod → Use Cases → Repository → SQLite.

Ketika internet tersedia:

SQLite Outbox → Dio → Laravel API → MySQL.

Data server terbaru:

Laravel API → Sync Manager → SQLite → Riverpod → Flutter UI.

## 3.4 Core Architecture Rules

1. UI tidak boleh melakukan query database secara langsung.
2. UI tidak boleh memanggil HTTP API secara langsung.
3. Seluruh operasi data harus melalui repository atau use case.
4. Repository menjadi satu-satunya sumber data bagi presentation layer.
5. SQLite menjadi sumber data langsung bagi UI.
6. API server tidak boleh menjadi dependency untuk menampilkan data yang sudah tersedia secara lokal.
7. Business logic keuangan harus konsisten pada client dan server.
8. Server tetap melakukan validasi ulang seluruh operasi.
9. Data keuangan tidak boleh diubah langsung melalui UI tanpa melalui business logic.
10. Operasi keuangan harus atomic.

---

# 4. USER MANAGEMENT & AUTHENTICATION

## 4.1 Registration

Pengguna dapat mendaftarkan akun menggunakan:

- Nama.
- Email.
- Password.
- Konfirmasi password.

Ketika registrasi berhasil, sistem harus:

1. Membuat akun pengguna.
2. Membuat user settings default.
3. Membuat kategori pemasukan default.
4. Membuat kategori pengeluaran default.
5. Membuat rekening Cash dengan saldo awal nol.
6. Mendaftarkan perangkat pertama ketika proses login perangkat selesai.

Semua proses pembuatan data awal harus aman terhadap kegagalan sebagian.

## 4.2 Login

Login menggunakan email dan password.

Server mengembalikan:

- User profile.
- Access token.
- Device information.
- Server synchronization metadata.

Gunakan Laravel Sanctum token authentication untuk mobile API.

Token harus disimpan menggunakan secure storage.

## 4.3 Multi-Device

Satu pengguna dapat login dari beberapa perangkat.

Setiap perangkat memiliki:

- UUID perangkat.
- Nama perangkat.
- Versi aplikasi.
- Status aktif.
- Waktu sinkronisasi terakhir.

Setiap operasi sinkronisasi harus terhubung dengan user ID dan device ID.

## 4.4 User Data Isolation

Seluruh data keuangan harus terikat pada user_id.

Server tidak boleh mempercayai user_id yang dikirim client tanpa validasi.

User ID untuk operasi terautentikasi harus diperoleh dari authenticated user.

Pengguna tidak boleh mengakses:

- Rekening pengguna lain.
- Transaksi pengguna lain.
- Kategori pengguna lain.
- Nota pengguna lain.
- Anggaran pengguna lain.
- Data sinkronisasi pengguna lain.

---

# 5. FUNCTIONAL REQUIREMENTS

# 5.1 Dashboard

Dashboard merupakan halaman utama.

### Data yang ditampilkan

1. Total saldo seluruh rekening.
2. Total pemasukan bulan berjalan.
3. Total pengeluaran bulan berjalan.
4. Selisih pemasukan dan pengeluaran.
5. Ringkasan rekening.
6. Grafik pemasukan dan pengeluaran.
7. Pengeluaran berdasarkan kategori.
8. Transaksi terbaru.
9. Ringkasan penggunaan anggaran.

### Interactions

- Memilih periode.
- Membuka detail rekening.
- Membuka detail transaksi.
- Membuka laporan.
- Menambah transaksi.
- Membuka scanner nota.

### Business Rules

Total saldo dihitung dari saldo seluruh rekening yang tidak diarsipkan.

Total pemasukan dan pengeluaran tidak memasukkan:

- Transfer.
- Opening balance.
- Account adjustments.
- Reversal movements secara terpisah.

Reversal hanya memengaruhi nilai bersih transaksi yang dilaporkan.

Dashboard harus tersedia dalam keadaan offline menggunakan data lokal.

# 5.2 Account Management

Mengelola sumber dana pengguna.

### Account Types

- cash.
- bank.
- e_wallet.
- other.

### Features

- Tambah rekening.
- Edit nama rekening.
- Edit jenis rekening.
- Tambah nama institusi.
- Tambah nomor rekening opsional.
- Menentukan saldo awal.
- Menentukan tanggal saldo awal.
- Memilih ikon.
- Memilih warna.
- Melihat saldo berjalan.
- Melihat riwayat mutasi.
- Mengarsipkan rekening.
- Melakukan koreksi saldo.

### Opening Balance

Saldo awal ditentukan ketika rekening dibuat.

Sistem membuat satu opening movement.

Opening movement:

- Tidak dihitung sebagai pemasukan.
- Tidak dihitung sebagai pengeluaran.
- Menjadi bagian dari perhitungan saldo.

Saldo awal tidak boleh diubah langsung setelah terdapat aktivitas keuangan.

Perubahan saldo awal harus menggunakan mekanisme penyesuaian yang tercatat.

### Negative Balance

Saldo negatif diperbolehkan.

Ketika saldo rekening menjadi negatif:

- Transaksi tetap disimpan.
- Saldo ditampilkan dengan jelas.
- Aplikasi dapat memberikan peringatan.
- Tidak boleh mengubah nilai transaksi secara otomatis.

### Account Archiving

Rekening yang sudah mempunyai histori transaksi tidak boleh dihapus secara permanen melalui aplikasi.

Rekening dapat diarsipkan.

Rekening yang diarsipkan:

- Tidak dapat dipilih pada transaksi baru.
- Tetap muncul dalam histori lama.
- Tetap diperhitungkan sesuai kebijakan tampilan saldo historis.
- Dapat diaktifkan kembali.

# 5.3 Category Management

Pengguna dapat membuat kategori sendiri.

### Category Types

- income.
- expense.

### Default Income Categories

- Gaji.
- Freelance.
- Bisnis.
- Investasi.
- Hadiah.
- Penjualan.
- Lainnya.

### Default Expense Categories

- Makanan.
- Transportasi.
- Belanja.
- Tagihan.
- Kesehatan.
- Pendidikan.
- Hiburan.
- Tempat Tinggal.
- Komunikasi.
- Lainnya.

### Features

- Tambah kategori.
- Edit kategori.
- Pilih ikon.
- Pilih warna.
- Ubah urutan.
- Aktifkan kategori.
- Nonaktifkan kategori.

### Business Rules

Kategori pemasukan hanya digunakan untuk transaksi pemasukan.

Kategori pengeluaran hanya digunakan untuk transaksi pengeluaran.

Transfer tidak menggunakan kategori.

Kategori yang sudah digunakan tidak boleh dihapus permanen.

Kategori yang dinonaktifkan tetap tersedia untuk menampilkan transaksi historis.

# 5.4 Transaction Management

Terdapat tiga jenis transaksi.

## A. Income

Data:

- UUID.
- Nominal.
- Kategori.
- Rekening tujuan.
- Tanggal.
- Deskripsi.
- Catatan.
- Lampiran.

Business logic:

Membuat satu account movement positif.

Contoh:

Pemasukan Rp500.000 ke BCA.

BCA: +Rp500.000.

## B. Expense

Data:

- UUID.
- Nominal.
- Kategori.
- Rekening sumber.
- Tanggal.
- Deskripsi.
- Catatan.
- Lampiran.

Business logic:

Membuat satu account movement negatif.

Contoh:

Pengeluaran Rp100.000 dari Cash.

Cash: -Rp100.000.

## C. Transfer

Data:

- UUID.
- Nominal.
- Rekening asal.
- Rekening tujuan.
- Tanggal.
- Deskripsi.
- Catatan.

Business logic:

Membuat satu transaksi utama dan tepat dua mutasi.

Contoh transfer Rp1.000.000 dari BCA ke Cash:

BCA: -Rp1.000.000.

Cash: +Rp1.000.000.

Total mutasi transfer harus nol.

Transfer tidak dihitung sebagai pemasukan maupun pengeluaran.

### General Transaction Features

- Create.
- Read.
- Update.
- Void.
- Search.
- Filter.
- Sort.
- Pagination.
- Receipt attachment.

### Transaction Validation

- Nominal harus lebih besar dari nol.
- Rekening harus dimiliki pengguna.
- Rekening harus aktif ketika transaksi baru dibuat.
- Kategori harus sesuai jenis transaksi.
- Transfer harus menggunakan dua rekening berbeda.
- Transfer tidak boleh memiliki kategori income/expense.
- Tanggal transaksi harus valid.
- Semua perubahan saldo harus melalui ledger.

# 5.5 Ledger & Account Movements

Ledger merupakan sumber kebenaran saldo.

Setiap perubahan saldo harus menghasilkan account movement.

### Movement Types

- opening.
- transaction.
- reversal.
- adjustment.

### Signed Amount

Positif berarti dana bertambah.

Negatif berarti dana berkurang.

Nol hanya diperbolehkan untuk opening movement.

### Balance Formula

Current Balance = SUM seluruh account movements pada rekening.

Kolom balance_cache hanya digunakan sebagai optimasi.

Ledger tetap menjadi sumber kebenaran.

### Ledger Rules

1. Mutasi yang sudah diposting tidak boleh diedit.
2. Mutasi yang sudah diposting tidak boleh dihapus.
3. Reversal harus menghasilkan nilai kebalikan.
4. Satu mutasi hanya dapat dibalik satu kali.
5. Transfer harus memiliki dua mutasi seimbang.
6. Opening movement hanya boleh dibuat satu kali per rekening.
7. Setiap mutasi harus memiliki sumber yang valid.
8. Semua mutasi harus berada dalam ownership pengguna yang sama dengan sumber transaksinya.

# 5.6 Transaction Revision & Reversal

Pengguna dapat mengedit dan membatalkan transaksi.

Namun, sistem harus mempertahankan histori.

### Editing Transaction

Contoh:
Pengeluaran awal Rp100.000 diubah menjadi Rp150.000.

Sistem:

1. Mengambil data transaksi dan mengunci record terkait.
2. Memeriksa version transaksi.
3. Membuat reversal untuk seluruh mutasi aktif lama.
4. Membuat posting baru.
5. Memperbarui data transaksi.
6. Menambah revision number.
7. Menyimpan before_data.
8. Menyimpan after_data.
9. Memperbarui cached balance.
10. Mencatat sync change.

### Voiding Transaction

Sistem:

1. Membuat reversal untuk seluruh mutasi aktif.
2. Mengubah status transaksi menjadi voided.
3. Menyimpan revision.
4. Memperbarui cached balance.
5. Mencatat sinkronisasi.

### Important Rules

- Jangan menggunakan hard delete untuk transaksi yang sudah diposting.
- Jangan menghapus mutasi sebelumnya.
- Jangan mengizinkan reversal ganda.
- Gunakan optimistic concurrency control.
- Semua perubahan dilakukan secara atomic.

# 5.7 Account Adjustments

Pengguna dapat melakukan koreksi saldo secara manual.

Contoh:
Saldo aktual Cash Rp950.000.
Saldo aplikasi Rp1.000.000.

Adjustment: -Rp50.000.

Adjustment:

- Memiliki alasan.
- Memiliki rekening.
- Memiliki nominal bertanda positif atau negatif.
- Menghasilkan satu account movement.
- Tidak dihitung sebagai pemasukan/pengeluaran.
- Tidak dapat dihapus permanen.

Jika perlu mengoreksi adjustment sebelumnya, buat adjustment baru dengan nilai berlawanan.

# 5.8 Receipt Scanner & OCR

Teknologi: Google ML Kit Text Recognition.

OCR dijalankan pada perangkat Android.

### Features

- Buka kamera.
- Ambil foto nota.
- Pilih foto dari galeri.
- Crop gambar.
- Rotasi gambar.
- Preview foto.
- Jalankan OCR.
- Ekstraksi data.
- Edit hasil ekstraksi.
- Simpan sebagai transaksi.
- Simpan lampiran.

### Target Extraction

- Nama toko.
- Tanggal.
- Nama barang.
- Harga barang.
- Kuantitas.
- Subtotal.
- Pajak.
- Biaya tambahan.
- Total.

### OCR Processing Flow

1. Pengguna mengambil gambar.
2. Aplikasi menjalankan ML Kit.
3. Aplikasi mendapatkan teks OCR.
4. Parser lokal mengidentifikasi kandidat informasi.
5. Form pengeluaran diisi secara otomatis.
6. Pengguna memeriksa hasil.
7. Pengguna menentukan kategori.
8. Pengguna menentukan rekening.
9. Pengguna menyimpan transaksi.

### Rules

OCR tidak boleh otomatis menyimpan transaksi.

Pengguna harus mengonfirmasi hasil.

OCR boleh gagal tanpa menghalangi pengguna menyimpan foto nota.

OCR harus dapat berjalan tanpa internet setelah model tersedia pada perangkat.

Jangan menganggap total nota selalu merupakan nilai transaksi yang benar. Pengguna harus dapat mengoreksi hasilnya.

### Receipt Storage

Foto disimpan lokal terlebih dahulu.

Ketika online:

- File dikompresi.
- Checksum dihitung.
- File diunggah.
- Server memvalidasi MIME type dan ukuran.
- Server menyimpan file secara privat.
- Metadata disimpan dalam tabel receipts.

Gunakan batas ukuran file yang dapat dikonfigurasi, dengan default rekomendasi 5 MB per gambar setelah kompresi.

# 5.9 Budget Management

### Features

- Membuat anggaran.
- Mengatur periode.
- Menentukan batas keseluruhan.
- Menentukan batas per kategori.
- Mengubah anggaran.
- Melihat penggunaan.
- Melihat sisa anggaran.
- Peringatan penggunaan.
- Riwayat anggaran.

### Period

Versi pertama mendukung anggaran bulanan.

### Budget Categories

Hanya kategori expense yang dapat dimasukkan.

### Calculation

Budget Usage = Total pengeluaran bersih pada kategori dalam periode anggaran.

Remaining Budget = Budget Limit - Budget Usage.

Percentage = Budget Usage / Budget Limit × 100%.

### Warning

Default:

- 80%: peringatan mendekati batas.
- 100%: anggaran tercapai atau terlampaui.

Pengguna dapat mengubah batas peringatan.

### Rules

- Transfer tidak dihitung sebagai pengeluaran.
- Reversal harus mengurangi penggunaan anggaran.
- Transaksi voided tidak dihitung.
- Perubahan kategori harus memperbarui laporan dan penggunaan anggaran.
- Budget report harus berdasarkan tanggal transaksi, bukan tanggal data dibuat.

# 5.10 Financial Reports

### Reports

1. Income Report.
2. Expense Report.
3. Net Cash Flow.
4. Account Balance Report.
5. Category Expense Report.
6. Category Income Report.
7. Account Movement Report.
8. Monthly Comparison.
9. Budget Utilization Report.

### Filters

- Today.
- This Week.
- This Month.
- Previous Month.
- This Year.
- Custom Date Range.

### Visualizations

- Bar Chart.
- Line Chart.
- Donut Chart.
- Progress Bars.

### Exports

- PDF.
- Excel.

### Rules

Laporan harus konsisten dengan ledger dan transaksi yang telah dikonfirmasi.

Laporan tidak boleh menghitung transfer sebagai pemasukan atau pengeluaran.

# 5.11 Settings

- Edit profil.
- Change password.
- Light mode.
- Dark mode.
- System theme.
- Notification preferences.
- Budget warning.
- Timezone.
- Currency display.
- Sync status.
- Manual synchronization.
- Device management.
- Logout.

Currency pada versi pertama hanya IDR.

---

# 6. COMPLETE DATABASE SPECIFICATION

## 6.1 Database Standards

Server:

- MySQL 8.0.16+.
- InnoDB.
- utf8mb4.
- CHAR(36) UUID.
- BIGINT untuk nominal.
- DATETIME(3) UTC.
- JSON untuk data tambahan.

Client:

- SQLite melalui Drift.
- UUID disimpan sebagai TEXT.
- Nominal menggunakan INTEGER.
- Timestamp menggunakan UTC.
- JSON disimpan sebagai TEXT.

## 6.2 Final Tables

Total 16 tabel:

### Identity

1. users
2. devices
3. user_settings

### Finance

4. accounts
5. categories
6. transactions
7. account_movements
8. account_adjustments

### Audit & Attachments

9. transaction_revisions
10. receipts

### Budgeting

11. budgets
12. budget_categories

### Synchronization

13. sync_operations
14. sync_cursors
15. sync_sequences
16. sync_changes

## 6.3 Core Table Definitions

### users

- id: CHAR(36), PK.
- name: VARCHAR(100), NOT NULL.
- email: VARCHAR(191), UNIQUE.
- password: VARCHAR(255), NOT NULL.
- email_verified_at: DATETIME(3), NULL.
- created_at.
- updated_at.
- deleted_at.

### devices

- id: CHAR(36), PK.
- user_id: CHAR(36), FK.
- device_name: VARCHAR(100).
- platform: VARCHAR(20).
- app_version: VARCHAR(30), NULL.
- last_sync_at: DATETIME(3), NULL.
- is_active: BOOLEAN.
- created_at.
- updated_at.

### user_settings

- id: CHAR(36), PK.
- user_id: CHAR(36), UNIQUE, FK.
- theme_mode: VARCHAR(20).
- currency: CHAR(3), IDR.
- timezone: VARCHAR(50).
- budget_warning_percent: TINYINT UNSIGNED.
- notifications_enabled: BOOLEAN.
- created_at.
- updated_at.

### accounts

- id: CHAR(36), PK.
- user_id: CHAR(36), FK.
- name: VARCHAR(100).
- account_type: VARCHAR(20).
- institution_name: VARCHAR(100), NULL.
- account_number: VARCHAR(50), NULL.
- opening_balance: BIGINT.
- opening_balance_date: DATE.
- balance_cache: BIGINT.
- icon: VARCHAR(50), NULL.
- color: VARCHAR(20), NULL.
- is_active: BOOLEAN.
- created_at.
- updated_at.
- deleted_at.

### categories

- id: CHAR(36), PK.
- user_id: CHAR(36), FK.
- name: VARCHAR(100).
- type: VARCHAR(20).
- icon: VARCHAR(50), NULL.
- color: VARCHAR(20), NULL.
- is_default: BOOLEAN.
- is_active: BOOLEAN.
- sort_order: INT.
- created_at.
- updated_at.
- deleted_at.

### transactions

- id: CHAR(36), PK.
- user_id: CHAR(36), FK.
- type: VARCHAR(20).
- category_id: CHAR(36), NULL.
- category_type: VARCHAR(20), NULL.
- amount: BIGINT UNSIGNED.
- transaction_date: DATETIME(3).
- description: VARCHAR(255), NULL.
- notes: TEXT, NULL.
- status: VARCHAR(20).
- created_by_device_id: CHAR(36), NULL.
- version: INT UNSIGNED.
- created_at.
- updated_at.
- deleted_at.

Important category rule:

- Income: category_type = income.
- Expense: category_type = expense.
- Transfer: category_id and category_type = NULL.

The database should use a composite foreign key from transactions to categories using category_id, user_id, and category_type.

### account_movements

- id: CHAR(36), PK.
- user_id: CHAR(36), FK.
- account_id: CHAR(36), FK.
- transaction_id: CHAR(36), NULL.
- adjustment_id: CHAR(36), NULL.
- posting_group_id: CHAR(36).
- movement_type: VARCHAR(20).
- amount_signed: BIGINT.
- reversal_of_id: CHAR(36), NULL.
- created_at.

### account_adjustments

- id: CHAR(36), PK.
- user_id: CHAR(36), FK.
- account_id: CHAR(36), FK.
- amount_signed: BIGINT.
- reason: VARCHAR(255).
- created_by_device_id: CHAR(36), NULL.
- created_at.

### transaction_revisions

- id: CHAR(36), PK.
- transaction_id: CHAR(36), FK.
- user_id: CHAR(36), FK.
- revision_number: INT UNSIGNED.
- action: VARCHAR(20).
- before_data: JSON, NULL.
- after_data: JSON, NULL.
- reason: VARCHAR(255), NULL.
- device_id: CHAR(36), NULL.
- created_at.

### receipts

- id: CHAR(36), PK.
- transaction_id: CHAR(36), FK.
- user_id: CHAR(36), FK.
- file_path: VARCHAR(500).
- file_name: VARCHAR(255), NULL.
- mime_type: VARCHAR(100).
- file_size: BIGINT UNSIGNED.
- checksum: VARCHAR(64), NULL.
- ocr_text: LONGTEXT, NULL.
- extracted_data: JSON, NULL.
- created_at.
- updated_at.

### budgets

- id: CHAR(36), PK.
- user_id: CHAR(36), FK.
- name: VARCHAR(100).
- period_type: VARCHAR(20).
- start_date: DATE.
- end_date: DATE.
- total_limit: BIGINT UNSIGNED, NULL.
- warning_percent: TINYINT UNSIGNED.
- is_active: BOOLEAN.
- created_at.
- updated_at.

### budget_categories

- id: CHAR(36), PK.
- user_id: CHAR(36).
- budget_id: CHAR(36), FK.
- category_id: CHAR(36), FK.
- amount_limit: BIGINT UNSIGNED.
- created_at.
- updated_at.

Unique:

- budget_id + category_id.

### sync_operations

- id: CHAR(36), PK.
- user_id: CHAR(36), FK.
- device_id: CHAR(36), FK.
- operation_id: CHAR(36).
- entity_type: VARCHAR(50).
- entity_id: CHAR(36).
- operation_type: VARCHAR(20).
- status: VARCHAR(20).
- response_data: JSON, NULL.
- created_at.

Unique:

- user_id + operation_id.

### sync_cursors

- id: CHAR(36), PK.
- user_id: CHAR(36), FK.
- device_id: CHAR(36), FK.
- last_cursor: BIGINT UNSIGNED.
- last_sync_at: DATETIME(3), NULL.
- created_at.
- updated_at.

Unique:

- user_id + device_id.

### sync_sequences

- user_id: CHAR(36), PK, FK.
- last_sequence: BIGINT UNSIGNED.

### sync_changes

- user_id: CHAR(36), FK.
- sequence: BIGINT UNSIGNED.
- entity_type: VARCHAR(50).
- entity_id: CHAR(36).
- operation: VARCHAR(20).
- entity_version: INT UNSIGNED.
- created_at.

Composite primary key:

- user_id + sequence.

## 6.4 Database Integrity Rules

1. Semua data keuangan harus memiliki user ownership.
2. Foreign key harus mencegah cross-user references.
3. Nominal transaksi harus lebih besar dari nol.
4. Saldo negatif diperbolehkan.
5. Mutasi tidak dapat diedit atau dihapus.
6. Reversal tidak boleh dilakukan dua kali pada satu mutasi.
7. Transfer wajib memiliki dua mutasi.
8. Transfer harus seimbang.
9. Opening movement maksimal satu per rekening.
10. Kategori harus sesuai jenis transaksi.
11. Budget hanya menerima kategori expense.
12. Setiap transaksi yang diposting harus memiliki mutasi yang benar.
13. Setiap operasi sinkronisasi memiliki idempotency key.
14. Semua perubahan server yang relevan harus menghasilkan sync change.
15. Penghapusan transaksi menggunakan tombstone dan reversal.
16. Saldo cache harus dapat direkonsiliasi dengan ledger.

## 6.5 Relationship & Cardinality

- User 1:N Devices.
- User 1:1 User Settings.
- User 1:N Accounts.
- User 1:N Categories.
- User 1:N Transactions.
- User 1:N Budgets.
- User 1:N Sync Operations.
- User 1:N Sync Cursors.
- Account 1:N Account Movements.
- Transaction 1:N Account Movements.
- Transaction 1:N Transaction Revisions.
- Transaction 1:N Receipts.
- Account 1:N Account Adjustments.
- Budget 1:N Budget Categories.
- Category 1:N Budget Categories.

Semua foreign key wajib menunjuk tepat satu parent record.

Parent record dapat memiliki nol atau banyak child record kecuali aturan khusus yang telah ditetapkan.

---

# 7. TRANSACTION ENGINE SPECIFICATION

## 7.1 Opening Balance

Ketika rekening dibuat:

1. Create account.
2. Save opening_balance.
3. Create opening movement.
4. Set balance_cache.
5. Create sync change.
6. Commit.

Semua dilakukan secara atomic.

Opening movement harus memiliki nominal yang sama dengan opening_balance.

Opening movement nol diperbolehkan.

Saldo berjalan:

Current Balance = SUM(account_movements.amount_signed).

Jangan menambahkan opening_balance kembali ke rumus tersebut.

## 7.2 Income

Input:

- Account.
- Category.
- Amount.
- Date.
- Description.

Output:

- Transaction.
- One positive account movement.
- One transaction revision.
- Sync change.

## 7.3 Expense

Input:

- Account.
- Category.
- Amount.
- Date.
- Description.

Output:

- Transaction.
- One negative account movement.
- One transaction revision.
- Sync change.

## 7.4 Transfer

Input:

- Source Account.
- Destination Account.
- Amount.
- Date.
- Description.

Output:

- One transaction.
- One negative movement.
- One positive movement.
- One revision.

Invariant:

SUM transfer movements = 0.

Source account and destination account must be different.

## 7.5 Edit

When editing an existing posted transaction:

1. Lock transaction.
2. Check current version.
3. Retrieve all currently active movements.
4. Create reversal movements.
5. Create replacement movements.
6. Update transaction attributes.
7. Increment version.
8. Store revision.
9. Update account balances.
10. Create sync changes.
11. Commit.

## 7.6 Void

1. Lock transaction.
2. Check version.
3. Reverse all active movements.
4. Mark transaction voided.
5. Increment version.
6. Store revision.
7. Update balances.
8. Record synchronization changes.
9. Commit.

## 7.7 Atomicity

All financial operations must use database transactions.

Use row-level locking with SELECT FOR UPDATE where appropriate.

Lock accounts in deterministic UUID order when multiple accounts are involved to reduce deadlocks.

Implement safe retry handling for deadlock errors.

---

# 8. OFFLINE-FIRST SPECIFICATION

## 8.1 Local-First Behavior

All main features must use SQLite as their local data source.

The application must not require internet access for:

- Viewing dashboard.
- Viewing accounts.
- Viewing categories.
- Creating income.
- Creating expenses.
- Creating transfers.
- Editing transactions.
- Voiding transactions.
- Viewing budgets.
- Viewing reports from locally available data.
- Taking receipt photos.
- OCR processing.

## 8.2 Local Transaction Atomicity

When saving a financial transaction locally:

1. Save transaction.
2. Save account movements.
3. Update balance cache.
4. Save transaction revision.
5. Insert outbox operation.
6. Commit SQLite transaction.

If any step fails, rollback all steps.

## 8.3 Outbox Pattern

Every local operation that requires server synchronization must have an outbox entry.

Outbox fields:

- id.
- user_id.
- entity_type.
- entity_id.
- operation_type.
- payload.
- status.
- retry_count.
- created_at.
- updated_at.

Statuses:

- pending.
- syncing.
- failed.
- synced.

## 8.4 Sync Push

Flutter sends pending operations to Laravel in batches.

Each operation has:

- operation_id.
- device_id.
- entity_type.
- entity_id.
- operation_type.
- base_version.
- payload.

Laravel:

1. Authenticates the user.
2. Validates device ownership.
3. Checks idempotency.
4. Checks entity ownership.
5. Checks version.
6. Executes the operation.
7. Saves sync operation result.
8. Updates ledger and balances if needed.
9. Creates server sync change.
10. Returns operation result.

Each operation must be processed atomically.

A failed operation must not partially modify financial records.

## 8.5 Sync Pull

Flutter requests:

- cursor.
- batch size.
- device ID.

Server returns:

- Changes.
- Sequence number.
- Entity type.
- Entity ID.
- Operation.
- Entity version.
- Next cursor.
- Has more.

Flutter applies changes to SQLite and advances the cursor only after successful local commit.

## 8.6 Sequence Consistency

Use per-user sync_sequences.

Server must:

1. Lock the user's sequence row.
2. Increment sequence.
3. Insert sync_changes.
4. Commit together with the underlying data mutation.

Do not use a plain timestamp as the sole synchronization cursor.

Do not advance cursor past uncommitted changes.

## 8.7 Multi-Device Conflict Resolution

Use optimistic concurrency control.

Each mutable entity has a version.

A client update must include base_version.

If the server version differs:

- Return conflict.
- Do not overwrite newer data.
- Provide current server version.
- Allow client to refresh or resolve.

Financial transactions must never use blind last-write-wins.

New transactions from separate devices should coexist when their UUIDs differ.

Duplicate operation IDs must return the previous result rather than executing twice.

## 8.8 Deletion Synchronization

Use tombstone records.

Do not physically delete synced entities immediately.

A delete operation must propagate to all devices.

Financial transaction deletion must be implemented as voiding plus reversal.

## 8.9 Offline Login

The user must have authenticated successfully at least once before offline access is enabled.

The application may use the locally stored session to unlock cached data, subject to local security policy.

Offline access must not be treated as server authentication for new remote operations.

---

# 9. API SPECIFICATION

Base URL:

`https://your-domain.com/api/v1`

All endpoints return JSON.

All protected endpoints require:

`Authorization: Bearer {access_token}`

Content type:

`application/json`

File uploads use `multipart/form-data`.

## 9.1 Standard Response

Success:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": {},
  "meta": {}
}
```

Error:

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {},
  "code": "VALIDATION_ERROR"
}
```

HTTP status codes:

- 200: Success.
- 201: Created.
- 204: No content.
- 400: Bad request.
- 401: Unauthenticated.
- 403: Forbidden.
- 404: Not found.
- 409: Conflict.
- 422: Validation error.
- 429: Rate limited.
- 500: Server error.

## 9.2 Authentication Endpoints

| Method | Endpoint       | Function                       |
| ------ | -------------- | ------------------------------ |
| POST   | /auth/register | Register                       |
| POST   | /auth/login    | Login                          |
| POST   | /auth/logout   | Logout                         |
| POST   | /auth/refresh  | Refresh session if implemented |
| GET    | /auth/me       | Current user                   |

Registration request:

```json
{
  "name": "Example User",
  "email": "user@example.com",
  "password": "secure-password",
  "password_confirmation": "secure-password",
  "device": {
    "id": "device-uuid",
    "name": "Android Phone",
    "platform": "android"
  }
}
```

## 9.3 Profile Endpoints

| Method | Endpoint          | Function        |
| ------ | ----------------- | --------------- |
| GET    | /profile          | Get profile     |
| PUT    | /profile          | Update profile  |
| PUT    | /profile/password | Change password |
| GET    | /settings         | Get settings    |
| PUT    | /settings         | Update settings |

## 9.4 Account Endpoints

| Method | Endpoint                   | Function          |
| ------ | -------------------------- | ----------------- |
| GET    | /accounts                  | List accounts     |
| POST   | /accounts                  | Create account    |
| GET    | /accounts/{id}             | Account detail    |
| PUT    | /accounts/{id}             | Update account    |
| POST   | /accounts/{id}/archive     | Archive           |
| POST   | /accounts/{id}/restore     | Restore           |
| GET    | /accounts/{id}/movements   | Movement history  |
| GET    | /accounts/{id}/balance     | Current balance   |
| POST   | /accounts/{id}/adjustments | Create adjustment |

Account creation:

```json
{
  "id": "account-uuid",
  "name": "BCA",
  "account_type": "bank",
  "institution_name": "Bank Central Asia",
  "opening_balance": 5000000,
  "opening_balance_date": "2026-11-21"
}
```

The server creates the opening movement automatically.

Clients must not submit an opening movement separately.

## 9.5 Category Endpoints

| Method | Endpoint                 | Function |
| ------ | ------------------------ | -------- |
| GET    | /categories              | List     |
| POST   | /categories              | Create   |
| GET    | /categories/{id}         | Detail   |
| PUT    | /categories/{id}         | Update   |
| POST   | /categories/{id}/archive | Disable  |
| POST   | /categories/{id}/restore | Restore  |

## 9.6 Transaction Endpoints

| Method | Endpoint                     | Function         |
| ------ | ---------------------------- | ---------------- |
| GET    | /transactions                | List             |
| POST   | /transactions                | Create           |
| GET    | /transactions/{id}           | Detail           |
| PUT    | /transactions/{id}           | Update           |
| POST   | /transactions/{id}/void      | Void             |
| GET    | /transactions/{id}/revisions | Revision history |

Income example:

```json
{
  "id": "transaction-uuid",
  "type": "income",
  "account_id": "account-uuid",
  "category_id": "category-uuid",
  "amount": 500000,
  "transaction_date": "2026-11-21T10:00:00Z",
  "description": "Monthly salary"
}
```

Expense example:

```json
{
  "id": "transaction-uuid",
  "type": "expense",
  "account_id": "account-uuid",
  "category_id": "category-uuid",
  "amount": 100000,
  "transaction_date": "2026-11-21T11:00:00Z",
  "description": "Lunch"
}
```

For transfer, use a dedicated endpoint.

## 9.7 Transfer Endpoints

| Method | Endpoint             | Function        |
| ------ | -------------------- | --------------- |
| POST   | /transfers           | Create transfer |
| GET    | /transfers           | List transfers  |
| GET    | /transfers/{id}      | Transfer detail |
| PUT    | /transfers/{id}      | Edit transfer   |
| POST   | /transfers/{id}/void | Cancel transfer |

Transfer request:

```json
{
  "id": "transaction-uuid",
  "source_account_id": "bca-uuid",
  "destination_account_id": "cash-uuid",
  "amount": 1000000,
  "transaction_date": "2026-11-21T12:00:00Z",
  "description": "Cash withdrawal"
}
```

The server must create one transaction and exactly two movements.

## 9.8 Receipt Endpoints

| Method | Endpoint                | Function                                       |
| ------ | ----------------------- | ---------------------------------------------- |
| POST   | /receipts               | Upload receipt                                 |
| GET    | /receipts/{id}          | Metadata                                       |
| GET    | /receipts/{id}/download | Authorized download                            |
| DELETE | /receipts/{id}          | Remove attachment according to retention rules |

The upload must validate:

- File size.
- MIME type.
- File signature.
- User ownership.
- Transaction ownership.
- Checksum.

## 9.9 Budget Endpoints

| Method | Endpoint              | Function           |
| ------ | --------------------- | ------------------ |
| GET    | /budgets              | List               |
| POST   | /budgets              | Create             |
| GET    | /budgets/{id}         | Detail             |
| PUT    | /budgets/{id}         | Update             |
| POST   | /budgets/{id}/archive | Archive            |
| GET    | /budgets/{id}/summary | Budget utilization |

## 9.10 Reports Endpoints

| Method | Endpoint                    | Function           |
| ------ | --------------------------- | ------------------ |
| GET    | /reports/overview           | Financial overview |
| GET    | /reports/income             | Income report      |
| GET    | /reports/expense            | Expense report     |
| GET    | /reports/cash-flow          | Cash flow          |
| GET    | /reports/categories         | Category analysis  |
| GET    | /reports/accounts           | Account report     |
| GET    | /reports/budgets            | Budget report      |
| GET    | /reports/monthly-comparison | Monthly comparison |

## 9.11 Synchronization Endpoints

| Method | Endpoint             | Function              |
| ------ | -------------------- | --------------------- |
| POST   | /devices/register    | Register device       |
| GET    | /devices             | List devices          |
| POST   | /devices/{id}/revoke | Revoke device         |
| POST   | /sync/push           | Push local operations |
| GET    | /sync/pull           | Pull server changes   |
| GET    | /sync/status         | Sync status           |

Push request:

```json
{
  "device_id": "device-uuid",
  "operations": [
    {
      "operation_id": "operation-uuid",
      "entity_type": "transactions",
      "entity_id": "transaction-uuid",
      "operation_type": "create",
      "base_version": 0,
      "payload": {}
    }
  ]
}
```

Push response must return an individual result for every operation.

Pull request:

```text
GET /sync/pull?cursor=100&limit=100
```

Pull response:

```json
{
  "success": true,
  "data": {
    "changes": [],
    "next_cursor": 120,
    "has_more": false
  }
}
```

Cursor may only advance after the corresponding local changes have been committed successfully.

---

# 10. UI/UX SPECIFICATION

## 10.1 Design Direction

The application must use Material Design 3.

Visual direction:

- Modern.
- Minimalist.
- Clean.
- Professional.
- Easy to navigate.
- Financial information must be visually clear.
- Avoid excessive decoration.

## 10.2 Color System

Recommended primary palette:

- Emerald / Teal.

Use Material 3 color roles rather than hardcoded colors throughout the application.

Financial semantic colors:

- Income: positive/success.
- Expense: error or negative.
- Transfer: neutral.
- Warning: warning.
- Balance: primary or neutral depending on context.

Support:

- Light Theme.
- Dark Theme.
- System Theme.

## 10.3 Typography

Use Material 3 Typography.

Prioritize:

- Readability.
- Clear financial number hierarchy.
- Consistent text scale.
- Proper Indonesian currency formatting.

## 10.4 Navigation

Bottom navigation:

1. Home.
2. Transactions.
3. Accounts.
4. Reports.
5. Settings.

A prominent add-transaction action should be available.

## 10.5 Main Screens

### Authentication

- Splash.
- Login.
- Register.
- Forgot Password.

### Home

- Dashboard.
- Balance summary.
- Income and expense.
- Account overview.
- Budget summary.
- Recent transactions.

### Transactions

- Transaction history.
- Transaction details.
- Add income.
- Add expense.
- Transfer.
- Edit transaction.
- Receipt scanner.
- Filters.

### Accounts

- Account list.
- Add account.
- Edit account.
- Account detail.
- Movement history.
- Adjustment.

### Categories

- Category list.
- Add category.
- Edit category.

### Budget

- Budget overview.
- Create budget.
- Budget details.
- Category allocation.

### Reports

- Financial overview.
- Income report.
- Expense report.
- Category chart.
- Account report.
- Monthly comparison.
- Export.

### Settings

- Profile.
- Theme.
- Notifications.
- Security.
- Sync.
- Devices.
- Logout.

## 10.6 Component Standards

Use Material 3 components:

- Scaffold.
- NavigationBar.
- NavigationDrawer where appropriate.
- Cards.
- FilledButton.
- OutlinedButton.
- FloatingActionButton.
- ModalBottomSheet.
- DatePicker.
- SegmentedButton.
- Dialog.
- Snackbar.
- LinearProgressIndicator.
- CircularProgressIndicator.

Forms must have clear validation and error messages.

All interactive elements must support appropriate touch targets and accessibility labels.

---

# 11. PROJECT STRUCTURE

## 11.1 Flutter

Use feature-first architecture with separation between presentation, application, domain, and data.

```text
mobile/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router.dart
│   │   └── providers.dart
│   ├── core/
│   │   ├── database/
│   │   ├── network/
│   │   ├── theme/
│   │   ├── security/
│   │   ├── sync/
│   │   ├── errors/
│   │   └── utils/
│   └── features/
│       ├── authentication/
│       ├── dashboard/
│       ├── accounts/
│       ├── categories/
│       ├── transactions/
│       ├── receipt_scanner/
│       ├── budgets/
│       ├── reports/
│       ├── settings/
│       └── devices/
├── test/
├── integration_test/
└── pubspec.yaml
```

Each feature should contain:

- data.
- domain.
- application.
- presentation.

## 11.2 Laravel

```text
backend/
├── app/
│   ├── Models/
│   ├── Http/
│   │   ├── Controllers/Api/V1/
│   │   ├── Requests/
│   │   ├── Resources/
│   │   └── Middleware/
│   ├── Services/
│   │   ├── AccountService.php
│   │   ├── TransactionService.php
│   │   ├── TransferService.php
│   │   ├── LedgerService.php
│   │   ├── BudgetService.php
│   │   ├── ReceiptService.php
│   │   └── SyncService.php
│   └── Exceptions/
├── database/
│   ├── migrations/
│   ├── seeders/
│   └── factories/
├── routes/
│   └── api.php
├── tests/
│   ├── Feature/
│   └── Unit/
└── composer.json
```

## 11.3 Documentation

```text
docs/
├── PRD.md
├── ARCHITECTURE.md
├── ERD.md
├── DATABASE_SPEC.md
├── API_SPEC.md
├── SYNC_SPEC.md
├── UI_UX_SPEC.md
├── BUSINESS_RULES.md
├── TESTING.md
└── DEPLOYMENT.md
```

---

# 12. SECURITY REQUIREMENTS

1. Use HTTPS.
2. Hash passwords securely.
3. Use Sanctum tokens.
4. Store tokens in secure storage.
5. Validate user ownership on every protected endpoint.
6. Validate all transaction input on the server.
7. Use parameterized database queries through Laravel.
8. Prevent mass-assignment vulnerabilities.
9. Rate-limit authentication endpoints.
10. Validate receipt MIME types and actual file signatures.
11. Store receipt files privately.
12. Do not expose database credentials in Flutter.
13. Do not embed API secrets in the mobile application.
14. Protect local user data from cross-account leakage.
15. Use database transactions for financial operations.
16. Maintain audit records.
17. Ensure backups are available.
18. Do not log passwords, access tokens, or sensitive financial information unnecessarily.

Local database encryption should be evaluated and implemented if supported by the selected SQLite configuration. At minimum, use secure storage for credentials and exclude sensitive files from insecure backups.

---

# 13. NON-FUNCTIONAL REQUIREMENTS

## Performance

- Local transaction saving should be immediate under normal device conditions.
- Dashboard should load from local database.
- API requests should use pagination where appropriate.
- Synchronization should use batches.
- Images should be compressed before upload.
- Reports should use indexed queries.

## Reliability

- Financial transactions must be atomic.
- Offline data must survive application restarts.
- Sync retry must not duplicate transactions.
- Failed synchronization must not destroy local data.
- Ledger must be reconcilable.

## Compatibility

- Android smartphones.
- Responsive layouts.
- Light and Dark Mode.
- Indonesian Rupiah formatting.
- Camera and gallery access.

## Availability

The Android application should remain useful without internet.

Server availability is required only for remote authentication, cloud synchronization, and remote data access.

---

# 14. ACCEPTANCE CRITERIA

The MVP is accepted when all the following are satisfied.

## Authentication

- User can register.
- User can login.
- User can logout.
- User can update profile.
- Different users cannot access each other's data.

## Accounts

- User can create multiple accounts.
- Opening balance is recorded once.
- Account balance is correct.
- Negative balances are allowed.
- Archived accounts preserve history.

## Categories

- User can create income categories.
- User can create expense categories.
- Category type is validated.
- Categories cannot be permanently deleted when referenced.

## Transactions

- User can create income.
- User can create expenses.
- User can create transfers.
- User can edit transactions.
- User can void transactions.
- Every operation updates balances correctly.
- Reversal history remains available.

## OCR

- User can capture receipt.
- OCR can extract text.
- OCR results can be edited.
- User must confirm before saving.
- Receipt can be stored offline.

## Budgeting

- User can create monthly budgets.
- User can allocate category limits.
- Spending usage is accurate.
- Warnings are displayed.

## Reports

- Reports are filterable.
- Transfers are excluded from income and expense totals.
- Reversals are accounted for correctly.
- Reports can be generated from local data.

## Offline

- Main financial features work offline.
- Local transactions survive restart.
- Pending operations are synchronized.
- Duplicate operations are prevented.
- Multi-device synchronization works.
- Conflicts are detected.

---

# 15. TESTING STRATEGY

## 15.1 Backend Tests

Use PHPUnit / Pest according to the Laravel project standard.

Test:

- Authentication.
- User ownership.
- Account creation.
- Opening balance.
- Income.
- Expense.
- Transfer.
- Reversal.
- Void.
- Adjustment.
- Budget calculation.
- Receipt ownership.
- Idempotency.
- Sync sequence.
- Concurrency.

## 15.2 Flutter Tests

Test:

- Widget rendering.
- Form validation.
- Repository operations.
- SQLite persistence.
- Ledger calculations.
- OCR parsing.
- Outbox insertion.
- Offline operations.
- Sync retry.
- Conflict handling.

## 15.3 Integration Tests

Scenarios:

1. Create account offline and synchronize.
2. Create income offline and synchronize.
3. Create expense offline and synchronize.
4. Create transfer offline and synchronize.
5. Edit transaction on one device.
6. Synchronize changes to another device.
7. Duplicate push request.
8. Simultaneous transaction creation on multiple devices.
9. Server unavailable during push.
10. Receipt upload interrupted.
11. Application restart with pending operations.
12. Login with a different user on the same device.

---

# 16. DEVELOPMENT ROADMAP

Development must be incremental.

## Phase 1 — Project Foundation

- Create Git repository.
- Initialize Flutter.
- Initialize Laravel.
- Configure MySQL.
- Configure Drift.
- Configure Riverpod.
- Configure GoRouter.
- Setup Material Design 3.
- Setup environment configuration.

Deliverable: working project foundation.

## Phase 2 — Database & Authentication

- Create migrations.
- Create models.
- Create relationships.
- Create seeders.
- Implement registration.
- Implement login.
- Implement profile.
- Implement device registration.

Deliverable: authentication and database foundation.

## Phase 3 — Core Financial Engine

- Accounts.
- Categories.
- Opening balance.
- Ledger.
- Income.
- Expense.
- Transfer.
- Reversal.
- Adjustment.
- Audit history.

Deliverable: accurate financial engine.

## Phase 4 — Mobile Finance UI

- Dashboard.
- Account screens.
- Category screens.
- Transaction screens.
- Transfer screens.
- Transaction history.
- Detail pages.

Deliverable: usable offline finance application.

## Phase 5 — Synchronization

- Outbox.
- Sync push.
- Sync pull.
- Idempotency.
- Sequence management.
- Conflict detection.
- Multi-device support.
- Tombstone synchronization.

Deliverable: complete Offline-First architecture.

## Phase 6 — Advanced Features

- Receipt scanner.
- OCR.
- Receipt uploads.
- Budgeting.
- Reports.
- Charts.
- Export PDF and Excel.

Deliverable: full feature set.

## Phase 7 — Quality Assurance

- Unit tests.
- Feature tests.
- Integration tests.
- Security testing.
- Performance testing.
- Offline testing.
- Multi-device testing.

Deliverable: release candidate.

## Phase 8 — Deployment

- Deploy Laravel to shared hosting.
- Configure MySQL.
- Configure HTTPS.
- Configure storage permissions.
- Configure backups.
- Build APK.
- Build AAB.
- Prepare release documentation.

Deliverable: production-ready application.

---

# 17. EXPLICIT OUT-OF-SCOPE FEATURES

The following features are not part of version 1.0:

- Automatic bank account integration.
- Bank statement synchronization.
- Payment processing.
- Family finance collaboration.
- Business accounting.
- Investment portfolio management.
- Debt and receivable management.
- AI financial assistant.
- AI financial predictions.
- Automatic AI categorization.
- Web dashboard.
- iOS application.
- Multi-currency conversion.

These may be considered for future releases but must not delay MVP development.

---

# 18. AI CODING AGENT IMPLEMENTATION INSTRUCTIONS

This section is mandatory for any AI agent implementing the project.

## 18.1 General Instructions

You are implementing Personal Finance Manager based on this document.

Treat this document as the authoritative product and technical specification.

Do not invent additional core business rules without documenting the proposed change.

Do not silently change the technology stack.

Do not omit requirements because they appear complicated.

Do not implement only UI mockups when functional behavior is required.

## 18.2 Architecture Rules

- Flutter is the Android frontend.
- Laravel is the backend.
- MySQL is the server database.
- SQLite/Drift is the local database.
- The app must be Offline-First.
- Material Design 3 is mandatory.
- Riverpod is the state management standard.
- Dio is the HTTP client.
- Laravel Sanctum is the mobile authentication mechanism.

## 18.3 Financial Rules — Highest Priority

These rules must never be violated:

1. Every financial operation must be atomic.
2. Ledger is the source of truth.
3. Opening balance must not be counted twice.
4. Transfers must create two opposite movements.
5. Transfers must not affect income or expense totals.
6. Negative account balances are allowed.
7. Posted movements cannot be edited or deleted.
8. Transaction editing must use reversal and replacement posting.
9. Voiding must use reversal.
10. Duplicate sync operations must not create duplicate financial records.
11. All records must respect user ownership.
12. Cached balance must reconcile with ledger.

## 18.4 Implementation Workflow

Before coding a feature:

1. Read the relevant specification.
2. Inspect existing project structure.
3. Identify dependencies.
4. Identify database changes.
5. Identify API changes.
6. Implement business logic.
7. Implement repository.
8. Implement state management.
9. Implement UI.
10. Write tests.
11. Run tests.
12. Document implementation.

Do not create duplicate services, models, repositories, or utilities when an existing implementation can be reused.

## 18.5 Incremental Development

Do not generate the entire application in one uncontrolled operation.

Implement one phase at a time.

At the end of every phase, provide:

- Files created.
- Files modified.
- Features completed.
- Database migrations.
- API endpoints.
- Tests executed.
- Test results.
- Known limitations.
- Next recommended task.

Do not mark a feature as completed unless it has working implementation and appropriate tests.

## 18.6 Database Migration Rules

- Use migrations, not manual database modifications as the primary development workflow.
- Keep migrations reversible where practical.
- Preserve UUID compatibility between Flutter and Laravel.
- Add foreign keys and indexes.
- Enforce financial constraints.
- Test clean installation from an empty database.
- Do not change existing production data without migration planning.

## 18.7 Synchronization Rules

- Never trust client-side financial validation alone.
- Use idempotency keys.
- Use per-user sequences.
- Use version checks.
- Preserve pending local changes.
- Do not use blind last-write-wins for financial transactions.
- Commit local cursor updates only after local data changes succeed.
- Handle retryable and non-retryable errors separately.

## 18.8 Code Quality

- Use clear naming.
- Separate concerns.
- Avoid large controllers.
- Keep financial business logic in dedicated services.
- Avoid unnecessary abstractions.
- Use typed models and DTOs.
- Document complex financial logic.
- Use automated tests.
- Avoid hardcoded secrets.
- Follow consistent formatting and linting.

## 18.9 Completion Definition

The project is complete only when:

- All agreed MVP features work.
- Backend and Flutter communicate correctly.
- Offline operation works.
- Synchronization works across multiple devices.
- Ledger and balances are consistent.
- OCR works.
- Budget calculations are accurate.
- Reports are accurate.
- Security and ownership rules are enforced.
- Tests pass.
- Android release build can be generated.
- Backend can be deployed to the target shared hosting.

---

# 19. FINAL PRODUCT DEFINITION

Personal Finance Manager is an Android-based, multi-user personal finance management application.

It uses Flutter with Material Design 3, Laravel REST API, MySQL, and SQLite through Drift.

Its architecture is Offline-First, allowing users to create and manage financial records without internet access and synchronize those records when connectivity returns.

Its financial engine uses an immutable ledger with reversible transaction operations, ensuring account balances remain traceable and consistent.

The first release focuses on:

- Authentication.
- Multi-account management.
- Income and expense tracking.
- Inter-account transfers.
- Custom categories.
- Receipt OCR.
- Budgeting.
- Financial reports.
- Offline operation.
- Multi-device synchronization.

This document is the authoritative implementation baseline for version 1.0.

Any proposed architectural or business-rule changes must be documented and approved before implementation.
