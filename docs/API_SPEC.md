# API Specification — Personal Finance Manager v1.0

**Base URL (Production):** `https://your-domain.com/api/v1`  
**Base URL (Local Development):** `http://127.0.0.1:8000/api/v1` (atau `http://10.0.2.2:8000/api/v1` untuk Android Emulator)  
**Format:** JSON (`Accept: application/json`, `Content-Type: application/json`), upload nota menggunakan `multipart/form-data`.  
**Authentication:** Laravel Sanctum Bearer Token (`Authorization: Bearer {access_token}`).

---

## 1. Standard Response Envelope (PRD Section 9.1)

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {},
  "meta": {}
}
```

### Error Response
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {},
  "code": "VALIDATION_ERROR"
}
```

### Standard HTTP Status Codes & Error Codes
| HTTP Status | Error Code (`code`) | Penggunaan |
|---|---|---|
| `200` | — | Berhasil (GET, PUT, POST action) |
| `201` | — | Berhasil membuat resource baru |
| `204` | — | Berhasil tanpa payload body |
| `400` | `BAD_REQUEST` | Permintaan tidak valid secara semantik |
| `401` | `UNAUTHENTICATED` | Token tidak ada, tidak valid, atau dicabut |
| `403` | `FORBIDDEN` | Akses ditolak / pelanggaran ownership `user_id` |
| `404` | `NOT_FOUND` | Endpoint atau resource tidak ditemukan |
| `409` | `CONFLICT` | Konflik versi optimistic concurrency (`base_version` != server `version`) |
| `422` | `VALIDATION_ERROR` | Gagal validasi FormRequest atau aturan domain |
| `429` | `RATE_LIMITED` | Melebihi batas rate-limit (khususnya auth endpoints) |
| `500` | `SERVER_ERROR` | Kesalahan internal server tak terduga |

---

## 2. Foundation & Health Endpoint (Aktif pada Phase 1)

| Method | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `GET` | `/api/v1/health` | Public | Verifikasi ketersediaan API v1, timestamp UTC, dan status koneksi database MySQL |

Contoh Response `GET /api/v1/health`:
```json
{
  "success": true,
  "message": "Service is healthy",
  "data": {
    "status": "ok",
    "version": "v1",
    "database": "connected",
    "timestamp": "2026-11-21T05:45:00.000Z"
  },
  "meta": {}
}
```

---

## 3. Target Endpoints (Implementasi Bertahap Phase 2 & 4)

### 3.1 Authentication (`/auth/*`)
| Method | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `POST` | `/api/v1/auth/register` | Public (rate-limited) | Registrasi user + settings + default categories + rekening Cash + device |
| `POST` | `/api/v1/auth/login` | Public (rate-limited) | Login email/password, mengembalikan Sanctum token + metadata sync |
| `POST` | `/api/v1/auth/logout` | Bearer | Mencabut token Sanctum perangkat saat ini |
| `POST` | `/api/v1/auth/refresh` | Bearer | Memperbarui sesi/token bila diperlukan |
| `GET` | `/api/v1/auth/me` | Bearer | Mengambil profil pengguna aktif |

### 3.2 Profile & Settings
| Method | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `GET` | `/api/v1/profile` | Bearer | Mengambil profil |
| `PUT` | `/api/v1/profile` | Bearer | Memperbarui profil |
| `PUT` | `/api/v1/profile/password` | Bearer | Mengubah password |
| `GET` | `/api/v1/settings` | Bearer | Mengambil `user_settings` |
| `PUT` | `/api/v1/settings` | Bearer | Memperbarui `user_settings` |

### 3.3 Accounts (`/accounts/*`)
| Method | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `GET` | `/api/v1/accounts` | Bearer | Daftar rekening milik user |
| `POST` | `/api/v1/accounts` | Bearer | Buat rekening + 1 opening movement atomik |
| `GET` | `/api/v1/accounts/{id}` | Bearer | Detail rekening |
| `PUT` | `/api/v1/accounts/{id}` | Bearer | Edit rekening (tanpa mengubah opening balance langsung) |
| `POST` | `/api/v1/accounts/{id}/archive` | Bearer | Arsipkan rekening |
| `POST` | `/api/v1/accounts/{id}/restore` | Bearer | Aktifkan kembali rekening |
| `GET` | `/api/v1/accounts/{id}/movements` | Bearer | Riwayat mutasi rekening |
| `GET` | `/api/v1/accounts/{id}/balance` | Bearer | Saldo berjalan dari ledger |
| `POST` | `/api/v1/accounts/{id}/adjustments` | Bearer | Koreksi saldo manual tercatat |

### 3.4 Categories (`/categories/*`)
| Method | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `GET` | `/api/v1/categories` | Bearer | Daftar kategori (`income` / `expense`) |
| `POST` | `/api/v1/categories` | Bearer | Tambah kategori baru |
| `GET` | `/api/v1/categories/{id}` | Bearer | Detail kategori |
| `PUT` | `/api/v1/categories/{id}` | Bearer | Update kategori |
| `POST` | `/api/v1/categories/{id}/archive` | Bearer | Nonaktifkan kategori |
| `POST` | `/api/v1/categories/{id}/restore` | Bearer | Aktifkan kembali kategori |

### 3.5 Transactions & Transfers
| Method | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `GET` | `/api/v1/transactions` | Bearer | List transaksi berpaginasi + filter |
| `POST` | `/api/v1/transactions` | Bearer | Buat transaksi `income` / `expense` |
| `GET` | `/api/v1/transactions/{id}` | Bearer | Detail transaksi |
| `PUT` | `/api/v1/transactions/{id}` | Bearer | Edit transaksi (via reversal + replacement posting) |
| `POST` | `/api/v1/transactions/{id}/void` | Bearer | Batalkan transaksi (via reversal + status `voided`) |
| `GET` | `/api/v1/transactions/{id}/revisions` | Bearer | Riwayat audit revisi transaksi |
| `POST` | `/api/v1/transfers` | Bearer | Buat transfer antar-rekening (2 mutasi seimbang = 0) |
| `GET` | `/api/v1/transfers` | Bearer | Daftar transfer |
| `GET` | `/api/v1/transfers/{id}` | Bearer | Detail transfer |
| `PUT` | `/api/v1/transfers/{id}` | Bearer | Edit transfer |
| `POST` | `/api/v1/transfers/{id}/void` | Bearer | Batalkan transfer |

### 3.6 Receipts (`/receipts/*`)
| Method | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `POST` | `/api/v1/receipts` | Bearer | Upload gambar nota (`multipart/form-data`, max 5 MB) + metadata OCR |
| `GET` | `/api/v1/receipts/{id}` | Bearer | Metadata nota |
| `GET` | `/api/v1/receipts/{id}/download` | Bearer | Unduh file nota secara privat setelah verifikasi ownership |
| `DELETE` | `/api/v1/receipts/{id}` | Bearer | Hapus lampiran sesuai aturan retensi |

### 3.7 Budgets & Reports
- **Budgets:** `GET /budgets`, `POST /budgets`, `GET /budgets/{id}`, `PUT /budgets/{id}`, `POST /budgets/{id}/archive`, `GET /budgets/{id}/summary`
- **Reports:** `GET /reports/overview`, `GET /reports/income`, `GET /reports/expense`, `GET /reports/cash-flow`, `GET /reports/categories`, `GET /reports/accounts`, `GET /reports/budgets`, `GET /reports/monthly-comparison`

### 3.8 Devices & Synchronization
- **Devices:** `POST /devices/register`, `GET /devices`, `POST /devices/{id}/revoke`
- **Sync:** `POST /sync/push`, `GET /sync/pull?cursor={seq}&limit={n}`, `GET /sync/status`

