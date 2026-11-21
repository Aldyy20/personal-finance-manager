import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_finance_manager/app/app.dart';
import 'package:personal_finance_manager/app/providers.dart';
import 'package:personal_finance_manager/core/database/app_database.dart';
import 'package:personal_finance_manager/core/security/secure_storage_service.dart';
import 'package:personal_finance_manager/features/receipt_scanner/application/ocr_parser_service.dart';
import 'package:personal_finance_manager/features/reports/presentation/reports_screen.dart';

class _InMemorySecureStorage extends SecureStorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> saveAccessToken(String token) async =>
      _store['access_token'] = token;

  @override
  Future<String?> getAccessToken() async => _store['access_token'];

  @override
  Future<void> saveSessionMetadata({
    required String userId,
    required String deviceId,
    required String email,
  }) async {
    _store['user_id'] = userId;
    _store['device_id'] = deviceId;
    _store['last_authenticated_email'] = email;
  }

  @override
  Future<String?> getUserId() async => _store['user_id'];

  @override
  Future<String?> getDeviceId() async => _store['device_id'] ?? 'test-device-001';

  @override
  Future<String?> getLastEmail() async => _store['last_authenticated_email'];

  @override
  Future<void> clearSession() async {
    _store.remove('access_token');
    _store.remove('user_id');
  }
}

Future<AppDatabase> _pumpAppWithMemoryDb(WidgetTester tester) async {
  final db = AppDatabase(NativeDatabase.memory());
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      secureStorageServiceProvider.overrideWithValue(_InMemorySecureStorage()),
      backendHealthProvider.overrideWith(
        (ref) async => {
          'status': 'ok',
          'version': 'v1',
          'database': 'connected',
        },
      ),
    ],
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    container.dispose();
    await tester.runAsync(() => db.close());
    await tester.pump(const Duration(milliseconds: 50));
  });

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const PersonalFinanceApp(),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Phase 6 Mobile UI & Advanced Features', () {
    test('OcrParserService accurately extracts Indonesian merchant, date, and IDR total', () {
      const parser = OcrParserService();

      final minimarket = parser.parseReceiptText(
        'INDOMARET SUDIRMAN\n'
        '21/11/2026 14:25\n'
        'Air Mineral 4.500\n'
        'Roti Tawar 18.500\n'
        'TOTAL Rp 23.000\n'
        'TUNAI 50.000\n'
        'KEMBALI 27.000',
      );
      expect(minimarket.merchantName, 'INDOMARET SUDIRMAN');
      expect(minimarket.detectedAmount, 23000);
      expect(minimarket.detectedDate, DateTime(2026, 11, 21));
      expect(minimarket.lineItems.length, 2);

      final decimalComma = parser.parseReceiptText(
        'APOTEK SEHAT\n'
        '2026-11-19\n'
        'Vitamin C 85.000\n'
        'JUMLAH TAGIHAN 125.000,00',
      );
      expect(decimalComma.merchantName, 'APOTEK SEHAT');
      expect(decimalComma.detectedAmount, 125000);
      expect(decimalComma.detectedDate, DateTime(2026, 11, 19));
    });

    testWidgets(
      'Dashboard renders hero net-worth stage and adapts NavigationBar <-> NavigationRail',
      timeout: const Timeout(Duration(seconds: 30)),
      (tester) async {
        await _pumpAppWithMemoryDb(tester);

        expect(find.text('TOTAL SALDO AKTIF (1 REKENING)'), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);

        // Navigate across all 5 branches
        await tester.tap(find.text('Transactions'));
        await tester.pumpAndSettle();
        expect(find.text('Riwayat Transaksi'), findsOneWidget);

        await tester.tap(find.text('Accounts'));
        await tester.pumpAndSettle();
        expect(find.text('Rekening & Dompet'), findsOneWidget);

        await tester.tap(find.text('Reports'));
        await tester.pumpAndSettle();
        expect(find.text('Laporan Keuangan'), findsOneWidget);

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        expect(find.text('Pengaturan'), findsOneWidget);

        // Resize viewport >= 840dp (tablet landscape) -> adaptive NavigationRail
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpAndSettle();
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
      },
    );

    testWidgets(
      'Accounts UI creates account and posts balance adjustment',
      timeout: const Timeout(Duration(seconds: 30)),
      (tester) async {
        await _pumpAppWithMemoryDb(tester);

        await tester.tap(find.text('Accounts'));
        await tester.pumpAndSettle();

        // Open AccountFormSheet
        await tester.tap(find.text('Tambah'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Rekening'),
          'BCA Utama',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Saldo Awal (Rp)'),
          '2000000',
        );
        await tester.ensureVisible(find.text('Buat Rekening'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Buat Rekening'));
        await tester.pumpAndSettle();

        expect(find.text('BCA Utama'), findsOneWidget);
        expect(find.text('Rp2.000.000'), findsWidgets);

        // Open AccountDetailSheet & create adjustment (-150.000)
        await tester.tap(find.text('BCA Utama'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Koreksi Saldo'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Kurang (-)'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nominal Koreksi (Rp)'),
          '150000',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Alasan Penyesuaian'),
          'Biaya admin bulanan',
        );
        await tester.tap(find.text('Simpan Koreksi'));
        await tester.pumpAndSettle();

        expect(find.text('Rp1.850.000'), findsWidgets);
      },
    );

    testWidgets(
      'Transactions UI creates income/expense, edits via reversal, and voids with audit trail',
      timeout: const Timeout(Duration(seconds: 30)),
      (tester) async {
        await _pumpAppWithMemoryDb(tester);

        // Create Income 3.000.000
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Masuk'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nominal (Rp)'),
          '3000000',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Deskripsi'),
          'Gaji Pokok',
        );
        await tester.ensureVisible(find.text('Simpan Transaksi'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Simpan Transaksi'));
        await tester.pumpAndSettle();

        // Create Expense 200.000
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nominal (Rp)'),
          '200000',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Deskripsi'),
          'Makan Siang',
        );
        await tester.ensureVisible(find.text('Simpan Transaksi'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Simpan Transaksi'));
        await tester.pumpAndSettle();

        // Go to Transactions tab and inspect detail -> Edit -> Void
        await tester.tap(find.text('Transactions'));
        await tester.pumpAndSettle();

        expect(find.text('Gaji Pokok'), findsOneWidget);
        expect(find.text('Makan Siang'), findsOneWidget);

        await tester.tap(find.text('Makan Siang'));
        await tester.pumpAndSettle();
        expect(find.text('Detail Transaksi'), findsOneWidget);

        // Edit 200.000 -> 250.000
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nominal (Rp)'),
          '250000',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Alasan Perubahan (Audit Revisi)'),
          'Tambah minum',
        );
        await tester.ensureVisible(find.text('Simpan Revisi (Reversal & Replace)'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Simpan Revisi (Reversal & Replace)'));
        await tester.pumpAndSettle();

        expect(find.text('POSTED • v2'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Riwayat Revisi Audit (2)'),
          200,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text('Riwayat Revisi Audit (2)'), findsOneWidget);

        // Scroll back up to tap Void
        await tester.scrollUntilVisible(
          find.text('Void'),
          -200,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.tap(find.text('Void'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Void Transaksi'));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('VOIDED (DIBATALKAN)'),
          -200,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text('VOIDED (DIBATALKAN)'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Riwayat Revisi Audit (3)'),
          200,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text('Riwayat Revisi Audit (3)'), findsOneWidget);
      },
    );

    testWidgets(
      'Receipt OCR confirmation saves transaction + receipt and Reports CSV exports cleanly',
      timeout: const Timeout(Duration(seconds: 30)),
      (tester) async {
        final db = await _pumpAppWithMemoryDb(tester);

        // Open Scan Struk from Dashboard Quick Actions
        await tester.tap(find.text('Scan Struk'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Struk Minimarket'));
        await tester.pumpAndSettle();

        expect(find.text('INDOMARET SUDIRMAN'), findsWidgets);
        expect(find.text('35000'), findsWidgets);

        final saveBtn = find.text('Konfirmasi & Simpan Transaksi + Struk');
        await tester.ensureVisible(saveBtn);
        await tester.pumpAndSettle();
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        final savedReceipts = await db.select(db.localReceipts).get();
        expect(savedReceipts.length, 1);
        expect(savedReceipts.first.fileName, 'struk_minimarket.jpg');

        // Verify Dashboard reflects -Rp35.000 expense
        expect(find.text('-Rp35.000'), findsWidgets);

        // Open Budgets via Quick Action button
        await tester.tap(find.text('Anggaran'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Buat Anggaran'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Batas Total (Rp, Opsional)'),
          '1000000',
        );
        await tester.ensureVisible(find.text('Simpan Anggaran'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Simpan Anggaran'));
        await tester.pumpAndSettle();

        expect(find.text('3.5%'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Open Reports tab & trigger CSV Export preview
        await tester.tap(find.text('Reports'));
        await tester.pumpAndSettle();

        expect(find.text('Perbandingan Bulanan (6 Bulan)'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Analisis Kategori'),
          200,
          scrollable: find.descendant(
            of: find.byType(ReportsScreen),
            matching: find.byType(Scrollable),
          ).first,
        );
        expect(find.text('Analisis Kategori'), findsOneWidget);

        await tester.tap(find.byTooltip('Ekspor CSV (Excel)'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Ringkasan,Total Pengeluaran,expense,-,35000'), findsOneWidget);
      },
    );
  });
}
