# Business Rules & Financial Engine Specification — Personal Finance Manager v1.0

Dokumen ini merangkum aturan bisnis inti dari [PRD.md](../PRD.md) Section 5, 6, 7, 8, dan 18.3 yang ditegakkan secara konsisten di backend **Laravel** dan frontend **Flutter Drift SQLite**.

---

## 1. Dua Belas Aturan Finansial Prioritas Tertinggi (PRD 18.3)

1. **Atomicity**: Seluruh mutasi finansial dieksekusi dalam database transaction (`DB::transaction` di Laravel dan `db.transaction` di Drift SQLite).
2. **Ledger Source of Truth**: Saldo rekening berasal dari penjumlahan buku besar:
   `Current Balance = SUM(account_movements.amount_signed)`.
3. **Opening Balance Recorded Once**: Saat rekening dibuat, satu mutasi `opening` dibuat sebesar `opening_balance`. Nilai `opening_balance` tidak pernah dijumlahkan ulang ke `SUM(account_movements)` dan tidak dapat diubah langsung via edit metadata rekening (`422 VALIDATION_ERROR`). Koreksi hanya melalui `account_adjustments`.
4. **Transfers Create Two Opposite Movements**: Setiap transfer antar rekening menghasilkan tepat **1 record transaksi** (`type = 'transfer'`, `category_id = null`) dan **2 mutasi berlawanan** dalam `posting_group_id` yang sama (`SUM = 0`).
5. **Transfers Neutral on Reports & Budgets**: Transfer dan transaksi berstatus `voided` dikecualikan dari total pemasukan (`income`), total pengeluaran (`expense`), net cash flow, dan realisasi anggaran (`budgets`).
6. **Negative Balances Allowed**: Saldo rekening bernilai negatif diperbolehkan.
7. **Immutable Ledger Movements**: Baris pada `account_movements` dan `transaction_revisions` bersifat permanen (dilarang diubah/dihapus). Model Eloquent menolak `updating` dan `deleting` pada kedua tabel tersebut (`LogicException`), dan engine Flutter hanya menyisipkan baris baru.
8. **Transaction Edit via Reversal + Replacement**: Mengedit transaksi yang sudah diposting membalik seluruh mutasi aktif sebelumnya dengan baris `reversal` baru (mengacu ke `reversal_of_id` unik), menyisipkan mutasi replacement baru, menaikkan `version`, dan menyimpan snapshot `before_data` / `after_data` di `transaction_revisions`.
9. **Voiding via Reversal**: Membatalkan transaksi membuat mutasi pembalik `reversal`, mengubah `status = 'voided'`, menaikkan `version`, dan menyimpan audit revisi `void`. Double-reversal pada satu `movement_id` dicegah di level database melalui constraint unik pada `reversal_of_id`.
10. **Idempotent Sync Operations**: Setiap entri outbox membawa `operation_id` (UUID). Mengirim ulang batch yang sama tidak mengeksekusi mutasi kedua kali melainkan mengembalikan hasil sebelumnya (`idempotent_replay: true`).
11. **Strict Ownership Isolation**: Seluruh entitas dimiliki tepat satu `user_id`. Foreign key komposit `(user_id, entity_id)` di MySQL serta pengecekan middleware/service API (`403 FORBIDDEN`) mencegah akses lintas pengguna. Saat login pengguna berbeda di perangkat sama, database SQLite lokal pengguna sebelumnya dibersihkan menyeluruh.
12. **Cached Balance Reconciliation**: `balance_cache` pada tabel `accounts` selalu direkonsiliasi langsung dari `SUM(account_movements.amount_signed)` di dalam transaksi yang sama.

---

## 2. Aturan Kategori, Anggaran & Sinkronisasi

- **Kesesuaian Tipe Kategori**: Transaksi `income` wajib menggunakan kategori `income`; transaksi `expense` wajib menggunakan kategori `expense`. Akun atau kategori terarsip (`is_active = false`) ditolak untuk transaksi baru sambil tetap menjaga riwayat transaksi lama.
- **Anggaran Pengeluaran Only**: Alokasi `budget_categories` hanya menerima kategori bertipe `expense`. Batas peringatan default adalah `80%` (`warning`), dan `>= 100%` berstatus `exceeded`.
- **Optimistic Concurrency Sync**: Setiap entitas mutable memiliki kolom `version`. Pembaruan klien menyertakan `base_version`; ketidakcocokan versi memicu respons `conflict` (`409 CONFLICT` pada REST API atau status `conflict` pada batch `/sync/push`) dan mutasi lokal yang belum terselesaikan tidak ditimpa secara sepihak saat `sync/pull`.
- **Per-User Cursor**: `sync_sequences` dikunci dan diinkrementasi per pengguna (`sync_changes`), dan kursor lokal di Flutter hanya dimajukan setelah seluruh entri batch berhasil dikomit secara atomik ke SQLite.

