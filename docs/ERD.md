# Entity-Relationship Diagram (ERD) — Personal Finance Manager v1.0

Dokumen ini memodelkan relasi seluruh **16 tabel MySQL/MariaDB server** (dengan UUID primary key + composite foreign keys untuk isolasi user ownership) serta pemetaannya ke **14 tabel SQLite lokal (Drift)** di Android.

---

## 1. Server MySQL Entity-Relationship Diagram

```mermaid
erDiagram
    USERS ||--o{ DEVICES : "owns"
    USERS ||--|| USER_SETTINGS : "has"
    USERS ||--|| SYNC_SEQUENCES : "tracks"
    USERS ||--o{ SYNC_CURSORS : "tracks per device"
    DEVICES ||--o{ SYNC_CURSORS : "maintains"
    USERS ||--o{ SYNC_OPERATIONS : "submits idempotent"
    DEVICES ||--o{ SYNC_OPERATIONS : "originates"
    USERS ||--o{ SYNC_CHANGES : "logs ordered mutations"

    USERS ||--o{ ACCOUNTS : "owns"
    USERS ||--o{ CATEGORIES : "owns"
    USERS ||--o{ TRANSACTIONS : "owns"
    USERS ||--o{ BUDGETS : "owns"

    ACCOUNTS ||--o{ ACCOUNT_MOVEMENTS : "has ledger"
    ACCOUNTS ||--o{ ACCOUNT_ADJUSTMENTS : "has adjustments"
    ACCOUNT_ADJUSTMENTS ||--|| ACCOUNT_MOVEMENTS : "generates movement"

    CATEGORIES ||--o{ TRANSACTIONS : "classifies"
    TRANSACTIONS ||--o{ ACCOUNT_MOVEMENTS : "posts immutable"
    ACCOUNT_MOVEMENTS ||--o| ACCOUNT_MOVEMENTS : "reversed_by (unique)"
    TRANSACTIONS ||--o{ TRANSACTION_REVISIONS : "audits"
    TRANSACTIONS ||--o{ RECEIPTS : "attaches"

    BUDGETS ||--o{ BUDGET_CATEGORIES : "allocates"
    CATEGORIES ||--o{ BUDGET_CATEGORIES : "tracked_in"

    USERS {
        char36 id PK
        string name
        string email UK
        timestamp email_verified_at
        string password
    }
    ACCOUNTS {
        char36 id PK
        char36 user_id FK
        string name
        string account_type
        bigint opening_balance
        date opening_balance_date
        bigint balance_cache
        boolean is_active
        int version
    }
    CATEGORIES {
        char36 id PK
        char36 user_id FK
        string name
        string type
        boolean is_default
        boolean is_active
        int version
    }
    TRANSACTIONS {
        char36 id PK
        char36 user_id FK
        string type
        char36 category_id FK
        bigint amount
        datetime transaction_date
        string status
        int version
    }
    ACCOUNT_MOVEMENTS {
        char36 id PK
        char36 user_id FK
        char36 account_id FK
        char36 transaction_id FK
        char36 adjustment_id FK
        char36 posting_group_id
        string movement_type
        bigint amount_signed
        char36 reversal_of_id UK
    }
    TRANSACTION_REVISIONS {
        char36 id PK
        char36 transaction_id FK
        char36 user_id FK
        int revision_number
        string action
        json before_data
        json after_data
        string reason
    }
    RECEIPTS {
        char36 id PK
        char36 transaction_id FK
        char36 user_id FK
        string file_path
        string mime_type
        bigint file_size
        string checksum
        text ocr_text
        json extracted_data
    }
    BUDGETS {
        char36 id PK
        char36 user_id FK
        string name
        date start_date
        date end_date
        bigint total_limit
        int warning_percent
        int version
    }
    BUDGET_CATEGORIES {
        char36 id PK
        char36 user_id FK
        char36 budget_id FK
        char36 category_id FK
        bigint amount_limit
    }
```

---

## 2. Kardinalitas & Jaminan Integritas Database

- **Isolasi Kepemilikan (`user_id` Composite Foreign Key):** Tabel child (`transactions`, `account_movements`, `budget_categories`, `receipts`) mereferensikan pasangan `(user_id, parent_id)` di MySQL agar cross-user reference mustahil disisipkan walau terjadi bug aplikasi.
- **Imutabilitas Ledger:**
  - `account_movements` dan `transaction_revisions` hanya memiliki operasi `INSERT`.
  - Kolom `reversal_of_id` memiliki constraint `UNIQUE`, memastikan setiap mutasi hanya dapat dibalik **satu kali**.
- **Pemetaan Lokal SQLite (`mobile/lib/core/database/app_database.dart`):**
  - 12 tabel mirror domain/user/device (`LocalUsers`, `LocalUserSettings`, `LocalDevices`, `LocalAccounts`, `LocalCategories`, `LocalTransactions`, `LocalAccountMovements`, `LocalAccountAdjustments`, `LocalTransactionRevisions`, `LocalReceipts`, `LocalBudgets`, `LocalBudgetCategories`)
  - 2 tabel infrastruktur offline sync (`LocalSyncState` untuk cursor perangkat, dan `SyncOutbox` untuk antrean push idempotent).

