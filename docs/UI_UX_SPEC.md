# UI/UX Design System Specification — Personal Finance Manager v1.0

**Visual Direction:** *Google Stitch "Livin-Style Finance Manager" (`Sapphire Dynamic`)* berbasis **Material Design 3** + angka berpresisi editorial (*tabular figures*), memadukan keamanan institusional perbankan Indonesia dengan kelincahan *super-app* modern.

---

## 1. Signature Identity (*Sapphire Dynamic* — Deep Sapphire, Electric Cobalt & Amber Gold)

- **Primary Deep Sapphire (`brandBlue` / `brandBlueDark`):**
  - Light Mode: `#002855` (*Deep Sapphire Navy*) -> `#001430` -> `#0054CC`
  - Dark Mode: `#0D286D` (*Luxury Sapphire*) -> `#091A44` -> `#050F29`
  - Digunakan pada *AppBar* (`StitchAppBarTitle` "FINANSIAL MANDIRI"), *Hero Financial Banner*, kartu debit virtual ISO ID-1, dan profil eksekutif.
- **Secondary Electric Cobalt (`brandBlueLight`):**
  - Light Mode: `#136BFB` | Dark Mode: `#1E60FF` / `#38BDF8`
  - Digunakan untuk tombol aksi utama (`FilledButton`, `FloatingActionButton`, tombol cepat *Bayar Cepat QRIS / Scan Struk*), *Quick Action Scan Struk* beraksen AI, serta tab navigasi aktif.
- **Tertiary Warm Amber Gold (`brandGold`):**
  - `#FFB956` (`onBrandGold #2A1800`) | Dark `#FFB95F` (`onBrandGold #2A1700`)
  - Digunakan untuk *Metallic EMV Chip* pada kartu debit virtual, lencana `AI` & `Priority`, penanda status terverifikasi, serta tombol aksi prioritas pada `AppBar`.
- **Canvases & Surfaces:**
  - Canvas background: Light `#FAF8FF` (*Sapphire Tinted Neutral*) | Dark `#091327` (*Deep Sapphire Night*).
  - Cards: Light `#FFFFFF` (`border #EAEDFF`) | Dark `#0E1B33` (`border #1E335A`), radius `16dp`.
- **Semantic Financial Colors (`FinancialColors`):**
  - `income`: Light `#00A86B` | Dark `#4ADE80`
  - `expense`: Light `#BA1A1A` | Dark `#F87171`
  - `transfer`: Light `#0054CC` | Dark `#38BDF8`
  - `warning`: Light `#F59E0B` | Dark `#FFB95F`

---

## 2. Pengalaman & Komponen Utama (Sesuai Google Stitch Screen Designs)

1. **Beranda (`DashboardScreen`):**
   - **Greeting & Realtime Sync Bar** dengan status sinkronisasi real-time (`TERSINKRON (CLOUD & LOKAL)` / `MODE OFFLINE AMAN`) dan tombol sync cepat.
   - **Hero Card "Total Aset Finansial"** lengkap dengan toggle **Intip Saldo** (`Rp ••••••••`), tren surplus bulanan, serta metrik *Pemasukan* & *Pengeluaran*.
   - **Tactile Quick Action Circles:** *Pengeluaran*, *Pemasukan*, *Transfer*, *Scan Struk* (badge `AI`), dan *Anggaran*.
   - **Budgeting Tracker** dengan *visual track* progres anggaran dan garis batas waspada merah (`warning_percent`, default 80%).
   - **Carousel "Rekening & Kas"** horizontal (*Bank*, *Tunai*, *E-Wallet*), banner **Insight Finansial**, daftar **Transaksi Terbaru**, dan tombol **Bayar Cepat QRIS / Scan Struk**.
2. **Rekening & Mutasi (`AccountsScreen` & `AccountDetailSheet`):**
   - Hero banner total saldo terkonsolidasi, pill filter tipe akun (`Semua`, `Bank`, `E-Wallet`, `Tunai`, `Arsip`), quick actions (`Transfer Keluar`, `Mutasi Rekening`, `Kategori`), dan **Kartu Debit Virtual ISO ID-1** dengan chip EMV emas serta tombol salin nomor rekening.
3. **Catat Transaksi & Scan Nota OCR (`TransactionFormSheet` & `ReceiptScannerSheet`):**
   - Banner nominal hero interaktif dengan tombol cepat (`+50 Rb`, `+100 Rb`, `+250 Rb`, `+500 Rb`) serta lencana informasi **Offline-First Engine**.
   - Review OCR dilengkapi indikator **OCR On-Device Engine (100% Offline)**, kartu simulasi bounding-box deteksi merchant/item/total, serta notifikasi SOP keamanan PRD sebelum konfirmasi simpan.
4. **Laporan & Pengaturan (`ReportsScreen` & `SettingsScreen`):**
   - Laporan dengan kartu **Periode Terpilih**, Hero **Arus Kas Bersih (Net)**, grafik batang perbandingan 6 bulan + ringkasan puncak pemasukan, **Insight Mandiri Pintar**, **Donut Chart Analisis Kategori**, dan tombol ekspor PDF/CSV.
   - Pengaturan dengan kartu profil **Priority**, grid 3-kolom **SQLite Local / Enkripsi / Outbox Pending**, preferensi mata uang IDR & limit anggaran, kontrol tema **Sapphire Dynamic**, dan diagnostik database.
5. **Navigasi Adaptif & Aksesibilitas:**
   - Smartphone (`< 840dp`): `NavigationBar` + `FloatingActionButton` lingkaran Electric Cobalt Blue.
   - Tablet / Landscape (`>= 840dp`): `NavigationRail` adaptif.
   - Target sentuh minimum `48×48dp` dan cakupan penuh state (`loading`, `empty`, `error`, `offline/sync`).
