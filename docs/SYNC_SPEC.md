# Synchronization Specification — Personal Finance Manager v1.0

**Model:** Offline-First Outbox Push + Per-User Sequence Cursor Pull  
**Target:** Konsistensi ledger mutlak lintas multi-perangkat tanpa kehilangan data offline dan tanpa duplikasi akibat retry jaringan.

---

## 1. Prinsip Dasar Offline-First

1. **Local SQLite = Primary UI Source:** Semua layar (Dashboard, Accounts, Transactions, Budgets, Reports) selalu membaca dari database lokal SQLite melalui Drift.
2. **Local Transaction Atomicity:** Setiap perubahan lokal (contoh: tambah transaksi) diproses dalam **1 transaksi SQLite atomik**:
   - Simpan/perbarui entitas (`transactions`, dll.).
   - Simpan `account_movements` & `transaction_revisions`.
   - Update `accounts.balance_cache`.
   - Sisipkan entri ke `sync_outbox` dengan `operation_id` UUID baru yang tetap dipertahankan saat retry.
3. **Auth Gate:** User harus berhasil login minimal 1 kali secara online. Sesi lokal (`FlutterSecureStorage`) membuka akses data cache lokal saat offline, namun operasi remote tetap memerlukan token Sanctum yang valid di server.

---

## 2. Outbox State Machine (Client)

Status pada tabel lokal `sync_outbox`:
- `pending`: Siap dikirim saat jaringan tersedia.
- `syncing`: Sedang dalam proses batch `POST /api/v1/sync/push`.
- `failed`: Gagal sementara (timeout, 5xx) → dijadwalkan retry dengan exponential backoff; data lokal tetap aman.
- `synced`: Berhasil diterapkan oleh server (atau terkonfirmasi idempoten) → ditandai selesai/dibersihkan sesuai kebijakan retensi outbox.
- *(Non-retryable errors seperti `409 Conflict` atau `422 Validation Error` ditandai agar pengguna dapat menyegarkan data dari server atau meninjau konflik, tidak diulang tanpa henti).*

---

## 3. Sync Push Protocol (`POST /api/v1/sync/push`)

### Payload Request
Client mengirim batch (rekomendasi maksimal **50 operasi per batch** untuk kestabilan shared hosting):
```json
{
  "device_id": "device-uuid",
  "operations": [
    {
      "operation_id": "op-uuid-v4",
      "entity_type": "transactions",
      "entity_id": "tx-uuid-v4",
      "operation_type": "create",
      "base_version": 0,
      "payload": {}
    }
  ]
}
```

### Server Processing Flow (Atomik Per Operasi)
Untuk setiap item operasi dalam batch:
1. Autentikasi pengguna via Sanctum (`$user = $request->user()`). Abaikan `user_id` apa pun yang dikirim payload.
2. Validasi bahwa `device_id` dimiliki oleh `$user->id` dan `is_active = true`.
3. **Cek Idempotency** pada `sync_operations` menggunakan `(user_id, operation_id)`. Jika sudah ada, langsung kembalikan `response_data` yang tersimpan tanpa mengeksekusi ulang.
4. Mulai `DB::transaction`:
   - Validasi ownership seluruh UUID referensi (rekening, kategori, dll.) milik `$user->id`.
   - Validasi `base_version` terhadap `entity.version` di database dengan `SELECT ... FOR UPDATE`. Jika berbeda, kembalikan hasil operasi berstatus `conflict` + `server_version` terbaru (tanpa menimpa data server).
   - Eksekusi logika bisnis melalui Service terkait (`AccountService`, `TransactionService`, `TransferService`, dll.).
   - Kunci baris `sync_sequences` milik `$user->id` (`SELECT ... FOR UPDATE`), naikkan `last_sequence + 1`, dan sisipkan baris baru ke `sync_changes`.
   - Simpan hasil pada `sync_operations`.
   - Commit transaksi.
5. Kembalikan array hasil individual untuk setiap `operation_id` dalam batch.

---

## 4. Sync Pull Protocol (`GET /api/v1/sync/pull`)

1. Client mengirim: `GET /api/v1/sync/pull?device_id={uuid}&cursor={last_cursor}&limit=100`
2. Server mengambil baris dari `sync_changes` di mana `user_id = $user->id` dan `sequence > cursor` berurutan naik (`ORDER BY sequence ASC LIMIT limit`).
3. Server melakukan **entity hydration** untuk setiap change record dengan menyertakan snapshot terbaru entitas (termasuk relasi mutasi untuk transaksi, atau penanda `deleted_at` untuk operasi tombstone delete).
4. Server mengembalikan:
   ```json
   {
     "success": true,
     "message": "Changes retrieved",
     "data": {
       "changes": [],
       "next_cursor": 120,
       "has_more": false
     },
     "meta": {}
   }
   ```
5. Client menerapkan seluruh `changes` ke SQLite dalam **1 transaksi database lokal**, dan **hanya memperbarui `last_cursor = next_cursor` setelah transaksi lokal commit sukses**.

---

## 5. Multi-Device Conflict & Tombstone Rules

- **No Blind Last-Write-Wins:** Transaksi finansial tidak boleh menimpa perubahan perangkat lain secara diam-diam.
- **Independent Creation:** Transaksi baru dari dua perangkat berbeda dengan `UUID` berbeda tidak akan berkonflik dan akan hidup berdampingan secara sah dalam ledger.
- **Tombstones:** Entitas yang disinkronkan tidak langsung di-hard-delete dari server. Penghapusan entitas non-ledger menggunakan `deleted_at` (soft delete tombstone) dan dicatat pada `sync_changes` agar seluruh perangkat lain menghapus/mengarsipkan data yang sama. Penghapusan transaksi finansial wajib menggunakan operasi **void + reversal**.
- **Receipt Upload Separation:** Upload file gambar nota dilakukan terpisah melalui `POST /api/v1/receipts` setelah metadata transaksi terkait tersedia/tersinkron, menggunakan kompresi lokal dan checksum SHA-256.

