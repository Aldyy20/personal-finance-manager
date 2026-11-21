# Database Specification — Personal Finance Manager v1.0

**Server Engine:** MySQL 8.0.16+ / MariaDB 10.4+ (Engine: `InnoDB`, Charset: `utf8mb4`, Collation: `utf8mb4_unicode_ci`)  
**Client Engine:** SQLite via Drift ORM  
**Standar Tipe Data:**
- Primary Key & Foreign Key: `CHAR(36)` (UUID v4 string) pada MySQL, `TEXT` pada SQLite.
- Nilai Uang (IDR): `BIGINT` (signed/unsigned sesuai konteks) dalam satuan Rupiah bulat tanpa desimal pada MySQL, `INTEGER` pada SQLite.
- Waktu: `DATETIME(3)` dalam **UTC** pada MySQL, `INTEGER` (epoch ms UTC) atau ISO-8601 UTC `TEXT` terstandar pada SQLite.
- Metadata Audit / OCR: `JSON` pada MySQL, `TEXT` pada SQLite.

> **Catatan Ruang Lingkup Phase 1:** Pada Phase 1 baru dijalankan migrasi fondasi (`users`, `personal_access_tokens`, `cache`, `jobs`, `sessions`). Ke-16 tabel domain lengkap di bawah ini akan diimplementasikan pada **Phase 2 — Database Implementation**.

---

## 1. Daftar 16 Tabel Server (MySQL)

### Kelompok A — Identity & Devices
1. **`users`**
   - `id` `CHAR(36)` PK
   - `name` `VARCHAR(100)` NOT NULL
   - `email` `VARCHAR(191)` UNIQUE NOT NULL
   - `password` `VARCHAR(255)` NOT NULL
   - `email_verified_at` `DATETIME(3)` NULL
   - `created_at`, `updated_at`, `deleted_at` `DATETIME(3)`

2. **`devices`**
   - `id` `CHAR(36)` PK
   - `user_id` `CHAR(36)` FK → `users(id)`
   - `device_name` `VARCHAR(100)` NOT NULL
   - `platform` `VARCHAR(20)` NOT NULL (`android`)
   - `app_version` `VARCHAR(30)` NULL
   - `last_sync_at` `DATETIME(3)` NULL
   - `is_active` `BOOLEAN` NOT NULL DEFAULT `TRUE`
   - `created_at`, `updated_at` `DATETIME(3)`
   - **Composite Unique Index:** `(id, user_id)`

3. **`user_settings`**
   - `id` `CHAR(36)` PK
   - `user_id` `CHAR(36)` UNIQUE FK → `users(id)`
   - `theme_mode` `VARCHAR(20)` NOT NULL DEFAULT `'system'` (`light`, `dark`, `system`)
   - `currency` `CHAR(3)` NOT NULL DEFAULT `'IDR'`
   - `timezone` `VARCHAR(50)` NOT NULL DEFAULT `'Asia/Jakarta'`
   - `budget_warning_percent` `TINYINT UNSIGNED` NOT NULL DEFAULT `80`
   - `notifications_enabled` `BOOLEAN` NOT NULL DEFAULT `TRUE`
   - `version` `INT UNSIGNED` NOT NULL DEFAULT `1` *(Rekomendasi konsistensi sync)*
   - `created_at`, `updated_at` `DATETIME(3)`

---

### Kelompok B — Finance & Immutable Ledger
4. **`accounts`**
   - `id` `CHAR(36)` PK
   - `user_id` `CHAR(36)` FK → `users(id)`
   - `name` `VARCHAR(100)` NOT NULL
   - `account_type` `VARCHAR(20)` NOT NULL (`cash`, `bank`, `e_wallet`, `other`)
   - `institution_name` `VARCHAR(100)` NULL
   - `account_number` `VARCHAR(50)` NULL
   - `opening_balance` `BIGINT` NOT NULL DEFAULT `0`
   - `opening_balance_date` `DATE` NOT NULL
   - `balance_cache` `BIGINT` NOT NULL DEFAULT `0`
   - `icon` `VARCHAR(50)` NULL
   - `color` `VARCHAR(20)` NULL
   - `is_active` `BOOLEAN` NOT NULL DEFAULT `TRUE`
   - `version` `INT UNSIGNED` NOT NULL DEFAULT `1`
   - `created_at`, `updated_at`, `deleted_at` `DATETIME(3)`
   - **Composite Unique Index:** `(id, user_id)`

5. **`categories`**
   - `id` `CHAR(36)` PK
   - `user_id` `CHAR(36)` FK → `users(id)`
   - `name` `VARCHAR(100)` NOT NULL
   - `type` `VARCHAR(20)` NOT NULL (`income`, `expense`)
   - `icon` `VARCHAR(50)` NULL
   - `color` `VARCHAR(20)` NULL
   - `is_default` `BOOLEAN` NOT NULL DEFAULT `FALSE`
   - `is_active` `BOOLEAN` NOT NULL DEFAULT `TRUE`
   - `sort_order` `INT` NOT NULL DEFAULT `0`
   - `version` `INT UNSIGNED` NOT NULL DEFAULT `1`
   - `created_at`, `updated_at`, `deleted_at` `DATETIME(3)`
   - **Composite Unique Indexes:** `(id, user_id)`, `(id, user_id, type)`

6. **`transactions`**
   - `id` `CHAR(36)` PK
   - `user_id` `CHAR(36)` FK → `users(id)`
   - `type` `VARCHAR(20)` NOT NULL (`income`, `expense`, `transfer`)
   - `category_id` `CHAR(36)` NULL
   - `category_type` `VARCHAR(20)` NULL
   - `amount` `BIGINT UNSIGNED` NOT NULL (`CHECK (amount > 0)`)
   - `transaction_date` `DATETIME(3)` NOT NULL
   - `description` `VARCHAR(255)` NULL
   - `notes` `TEXT` NULL
   - `status` `VARCHAR(20)` NOT NULL DEFAULT `'posted'` (`posted`, `voided`)
   - `created_by_device_id` `CHAR(36)` NULL
   - `version` `INT UNSIGNED` NOT NULL DEFAULT `1`
   - `created_at`, `updated_at`, `deleted_at` `DATETIME(3)`
   - **Composite Unique Index:** `(id, user_id)`
   - **Composite Foreign Key:** `(category_id, user_id, category_type)` → `categories(id, user_id, type)`
   - **Device Foreign Key:** `(created_by_device_id, user_id)` → `devices(id, user_id)`
   - **Category Rule Check:** `(type = 'transfer' AND category_id IS NULL AND category_type IS NULL) OR (type IN ('income', 'expense') AND category_id IS NOT NULL AND category_type = type)`

7. **`account_adjustments`**
   - `id` `CHAR(36)` PK
   - `user_id` `CHAR(36)` FK → `users(id)`
   - `account_id` `CHAR(36)` NOT NULL
   - `amount_signed` `BIGINT` NOT NULL (`CHECK (amount_signed <> 0)`)
   - `reason` `VARCHAR(255)` NOT NULL
   - `created_by_device_id` `CHAR(36)` NULL
   - `created_at` `DATETIME(3)` NOT NULL
   - **Composite Unique Index:** `(id, user_id)`
   - **Composite Foreign Key:** `(account_id, user_id)` → `accounts(id, user_id)`

8. **`account_movements`** *(Ledger — Sumber Kebenaran Saldo)*
   - `id` `CHAR(36)` PK
   - `user_id` `CHAR(36)` FK → `users(id)`
   - `account_id` `CHAR(36)` NOT NULL
   - `transaction_id` `CHAR(36)` NULL
   - `adjustment_id` `CHAR(36)` NULL
   - `posting_group_id` `CHAR(36)` NOT NULL
   - `movement_type` `VARCHAR(20)` NOT NULL (`opening`, `transaction`, `reversal`, `adjustment`)
   - `amount_signed` `BIGINT` NOT NULL
   - `reversal_of_id` `CHAR(36)` NULL UNIQUE *(Menjamin 1 mutasi hanya dapat dibalik maksimal 1 kali)*
   - `created_at` `DATETIME(3)` NOT NULL
   - **Composite Foreign Keys:**
     - `(account_id, user_id)` → `accounts(id, user_id)`
     - `(transaction_id, user_id)` → `transactions(id, user_id)`
     - `(adjustment_id, user_id)` → `account_adjustments(id, user_id)`
   - **Self Foreign Key:** `reversal_of_id` → `account_movements(id)`
   - **Invariants:**
     - `Current Balance = SUM(account_movements.amount_signed)` per `account_id`.
     - Mutasi yang sudah diposting tidak boleh di-`UPDATE` maupun di-`DELETE`.
     - Transfer wajib menghasilkan tepat 2 mutasi dengan `posting_group_id` sama dan jumlah `amount_signed` = `0`.

---

### Kelompok C — Audit & Attachments
9. **`transaction_revisions`**
   - `id` `CHAR(36)` PK
   - `transaction_id` `CHAR(36)` NOT NULL
   - `user_id` `CHAR(36)` NOT NULL
   - `revision_number` `INT UNSIGNED` NOT NULL
   - `action` `VARCHAR(20)` NOT NULL (`create`, `edit`, `void`)
   - `before_data` `JSON` NULL
   - `after_data` `JSON` NULL
   - `reason` `VARCHAR(255)` NULL
   - `device_id` `CHAR(36)` NULL
   - `created_at` `DATETIME(3)` NOT NULL
   - **Unique:** `(transaction_id, revision_number)`
   - **Composite FK:** `(transaction_id, user_id)` → `transactions(id, user_id)`

10. **`receipts`**
    - `id` `CHAR(36)` PK
    - `transaction_id` `CHAR(36)` NOT NULL
    - `user_id` `CHAR(36)` NOT NULL
    - `file_path` `VARCHAR(500)` NOT NULL
    - `file_name` `VARCHAR(255)` NULL
    - `mime_type` `VARCHAR(100)` NOT NULL
    - `file_size` `BIGINT UNSIGNED` NOT NULL
    - `checksum` `VARCHAR(64)` NULL
    - `ocr_text` `LONGTEXT` NULL
    - `extracted_data` `JSON` NULL
    - `version` `INT UNSIGNED` NOT NULL DEFAULT `1`
    - `created_at`, `updated_at`, `deleted_at` `DATETIME(3)`
    - **Composite FK:** `(transaction_id, user_id)` → `transactions(id, user_id)`

---

### Kelompok D — Budgeting
11. **`budgets`**
    - `id` `CHAR(36)` PK
    - `user_id` `CHAR(36)` FK → `users(id)`
    - `name` `VARCHAR(100)` NOT NULL
    - `period_type` `VARCHAR(20)` NOT NULL DEFAULT `'monthly'`
    - `start_date` `DATE` NOT NULL
    - `end_date` `DATE` NOT NULL
    - `total_limit` `BIGINT UNSIGNED` NULL
    - `warning_percent` `TINYINT UNSIGNED` NOT NULL DEFAULT `80`
    - `is_active` `BOOLEAN` NOT NULL DEFAULT `TRUE`
    - `version` `INT UNSIGNED` NOT NULL DEFAULT `1`
    - `created_at`, `updated_at`, `deleted_at` `DATETIME(3)`
    - **Composite Unique Index:** `(id, user_id)`

12. **`budget_categories`**
    - `id` `CHAR(36)` PK
    - `user_id` `CHAR(36)` NOT NULL
    - `budget_id` `CHAR(36)` NOT NULL
    - `category_id` `CHAR(36)` NOT NULL
    - `category_type` `VARCHAR(20)` NOT NULL DEFAULT `'expense'` *(Menegakkan hanya kategori expense)*
    - `amount_limit` `BIGINT UNSIGNED` NOT NULL
    - `version` `INT UNSIGNED` NOT NULL DEFAULT `1`
    - `created_at`, `updated_at`, `deleted_at` `DATETIME(3)`
    - **Unique:** `(budget_id, category_id)`
    - **Composite FKs:**
      - `(budget_id, user_id)` → `budgets(id, user_id)`
      - `(category_id, user_id, category_type)` → `categories(id, user_id, type)` (with `CHECK (category_type = 'expense')`)

---

### Kelompok E — Synchronization
13. **`sync_operations`** *(Idempotency Log)*
    - `id` `CHAR(36)` PK
    - `user_id` `CHAR(36)` NOT NULL
    - `device_id` `CHAR(36)` NOT NULL
    - `operation_id` `CHAR(36)` NOT NULL
    - `entity_type` `VARCHAR(50)` NOT NULL
    - `entity_id` `CHAR(36)` NOT NULL
    - `operation_type` `VARCHAR(20)` NOT NULL
    - `status` `VARCHAR(20)` NOT NULL (`applied`, `conflict`, `rejected`)
    - `response_data` `JSON` NULL
    - `created_at` `DATETIME(3)` NOT NULL
    - **Unique:** `(user_id, operation_id)`
    - **Composite FK:** `(device_id, user_id)` → `devices(id, user_id)`

14. **`sync_cursors`**
    - `id` `CHAR(36)` PK
    - `user_id` `CHAR(36)` NOT NULL
    - `device_id` `CHAR(36)` NOT NULL
    - `last_cursor` `BIGINT UNSIGNED` NOT NULL DEFAULT `0`
    - `last_sync_at` `DATETIME(3)` NULL
    - `created_at`, `updated_at` `DATETIME(3)`
    - **Unique:** `(user_id, device_id)`
    - **Composite FK:** `(device_id, user_id)` → `devices(id, user_id)`

15. **`sync_sequences`**
    - `user_id` `CHAR(36)` PK, FK → `users(id)`
    - `last_sequence` `BIGINT UNSIGNED` NOT NULL DEFAULT `0`

16. **`sync_changes`**
    - `user_id` `CHAR(36)` NOT NULL, FK → `users(id)`
    - `sequence` `BIGINT UNSIGNED` NOT NULL
    - `entity_type` `VARCHAR(50)` NOT NULL
    - `entity_id` `CHAR(36)` NOT NULL
    - `operation` `VARCHAR(20)` NOT NULL (`create`, `update`, `void`, `delete`)
    - `entity_version` `INT UNSIGNED` NOT NULL
    - `created_at` `DATETIME(3)` NOT NULL
    - **Composite Primary Key:** `(user_id, sequence)`

---

## 2. Local SQLite / Drift Schema (`mobile/`)

Database lokal diaktifkan dengan `PRAGMA foreign_keys = ON;`.
Selain mereplikasi data bisnis dari 12 tabel inti user/finance/audit/budgeting, SQLite memiliki tabel khusus client:
- **`sync_outbox`**:
  - `id` `TEXT` PK
  - `operation_id` `TEXT` UNIQUE NOT NULL
  - `user_id` `TEXT` NOT NULL
  - `device_id` `TEXT` NOT NULL
  - `entity_type` `TEXT` NOT NULL
  - `entity_id` `TEXT` NOT NULL
  - `operation_type` `TEXT` NOT NULL (`create`, `update`, `void`, `archive`, `restore`, `adjustment`, `delete`)
  - `base_version` `INTEGER` NOT NULL DEFAULT `0`
  - `payload` `TEXT` (JSON) NOT NULL
  - `status` `TEXT` NOT NULL DEFAULT `'pending'` (`pending`, `syncing`, `failed`, `synced`)
  - `retry_count` `INTEGER` NOT NULL DEFAULT `0`
  - `last_error` `TEXT` NULL
  - `created_at` `INTEGER` (UTC epoch ms) NOT NULL
  - `updated_at` `INTEGER` (UTC epoch ms) NOT NULL
- **`local_sync_state`**: Menyimpan `user_id`, `device_id`, `last_cursor`, `last_sync_at` untuk tracking sinkronisasi perangkat saat ini.

