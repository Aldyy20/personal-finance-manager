# UI/UX Design System Specification — Personal Finance Manager v1.0

**Guiding Standards:**
1. **Material Design 3 (`material-design-3-ui`)**: Semantic color roles, adaptive navigation, M3 component semantics, dan anti-pattern discipline.
2. **Awwwards Editorial Craft (`awwwards`)**: Concept-driven hierarchy, poster-grade typography dengan angka tabular yang presisi, serta satu *signature moment* di tiap halaman utama tanpa dekorasi berlebihan.
3. **UI/UX Pro Max (`ui-ux-pro-max`)**: Ritme spasi 4/8dp, target sentuh minimal 48×48dp Android, kontras WCAG AA di Light & Dark mode, ikon vektor murni (tanpa emoji), serta cakupan penuh state (`loading`, `empty`, `error + recovery`, `offline/sync`).

---

## 1. Concept Card (*Editorial Precision Ledger*)

- **Idea:** Buku besar finansial pribadi berpresisi tinggi yang menyajikan kondisi arus kas secara jujur dalam < 3 detik.
- **Metaphor:** Ledger cetak modern (*modern editorial passbook*) yang bersih, tegas pada tipografi nominal, dan tenang pada permukaan (*surface*).
- **Signature Moment:** *Hero Net-Worth & Cash-Flow Stage* di Dashboard — menampilkan total aset aktif dengan tipografi display berfitur `tabular-nums`, indikator status sinkronisasi yang jelas (bukan hanya warna, tapi juga ikon & teks), dan transisi mulus antarperiode.
- **Motion Verb:** *Settle cleanly* (`180–240ms`, `Curves.easeOutCubic`), menghormati `MediaQuery.disableAnimationsOf(context)` (*reduced-motion*).

---

## 2. Design Tokens (`mobile/lib/core/theme/design_tokens.dart`)

### 2.1 Color System (Semantic Roles — Zero Hardcoded Screen Colors)
- **M3 Seed:** `#00796B` (Emerald / Teal).
- **Surfaces:** Gunakan `colorScheme.surface`, `surfaceContainerLow`, `surfaceContainer`, `surfaceContainerHigh`, `onSurface`, `onSurfaceVariant`, `outlineVariant` — dilarang keras menyisipkan hex warna mentah di file screen.
- **Financial Semantic Extension (`FinancialColors`):**
  - `income` (positif): Light `#1B8A5A` | Dark `#6DD58C`
  - `expense` (negatif): Light `#BA1A1A` | Dark `#FFB4AB`
  - `transfer` (netral): Light `#3F5F90` | Dark `#A8C7FA`
  - `warning` (budget >= 80%): Light `#B45309` | Dark `#FBBF24`
  - `balance`: Light `#00695C` | Dark `#80CBC4`
- **Non-Color Indicators:** Setiap perubahan nominal wajib disertai tanda/ikon (`+` / panah naik untuk income, `-` / panah turun untuk expense, ikon swap untuk transfer), bukan warna semata.

### 2.2 Typography & Numeric Discipline
- Seluruh nominal Rupiah (`Rp`) menggunakan `FontFeature.tabularFigures()` agar kolom angka lurus vertikal dan mudah dipindai.
- Hierarki tipe jelas:
  - Hero Total Saldo: `displaySmall` / `headlineLarge` (`fontWeight: w700`, tight tracking `-0.5`, tabular).
  - Judul Seksi: `titleMedium` (`w600`).
  - Label & Meta: `bodyMedium` / `labelMedium` (minimal `12sp`, kontras >= 4.5:1 untuk teks utama, >= 3:1 untuk teks sekunder).

### 2.3 Spacing, Radius & Motion
- **4/8dp Rhythm (`AppSpacing`):** `xs = 4`, `sm = 8`, `md = 12`, `lg = 16`, `xl = 24`, `xxl = 32`, `section = 48`.
- **Shape (`AppRadius`):** `sm = 8`, `md = 12`, `lg = 16`, `xl = 24` (hindari *pill-radius* berlebihan di semua kontrol dan hindari membungkus setiap baris list ke dalam Card terpisah).
- **Motion (`AppMotion`):** `fast = 150ms`, `normal = 220ms`, `emphasized = 280ms` (`Curves.easeOutCubic`).

---

## 3. Adaptive Layout & Navigation

- **Compact & Medium (< 840dp — Smartphone):** Bottom `NavigationBar` dengan 5 destinasi tetap sesuai PRD Section 10.4 (`Home`, `Transactions`, `Accounts`, `Reports`, `Settings`) + 1 `FloatingActionButton` utama (*Tambah Transaksi*).
- **Expanded (>= 840dp — Tablet / Landscape / Foldable):** Beradaptasi otomatis menjadi `NavigationRail` di sisi kiri + `FloatingActionButton` pada header rail agar konten memiliki *readable measure* (maks. lebar konten terfokus) tanpa meregangkan form/daftar secara canggung.
- **Safe Area & Clearance:** Daftar scroll selalu memiliki *bottom padding* cukup agar item terbawah tidak tertutup `FloatingActionButton` atau `NavigationBar`.

---

## 4. State Coverage & Accessibility Checklist

- **Touch Targets:** Minimal `48×48dp` pada seluruh kontrol interaktif Android.
- **Icons:** 100% Material vector icons konsisten (dilarang memakai emoji untuk ikon navigasi/status).
- **Form Validation:** Seluruh input menggunakan `Form` + `GlobalKey<FormState>` dengan label terlihat permanen, pesan error tepat di bawah field terkait, serta format angka yang ramah keyboard numerik.
- **Required States:** Setiap layar data harus menangani `loading` (skeleton/progress), `empty` (instruksi aksi jelas), `error` (pesan ramah + tombol coba lagi), dan badge status `offline / pending sync`.

