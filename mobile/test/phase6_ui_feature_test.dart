import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_finance_manager/app/app.dart';
import 'package:personal_finance_manager/app/providers.dart';
import 'package:personal_finance_manager/core/config/env_config.dart';
import 'package:personal_finance_manager/core/database/app_database.dart';
import 'package:personal_finance_manager/core/network/api_client.dart';
import 'package:personal_finance_manager/core/security/biometric_auth_service.dart';
import 'package:personal_finance_manager/core/security/secure_storage_service.dart';
import 'package:personal_finance_manager/features/authentication/presentation/auth_screen.dart';
import 'package:personal_finance_manager/features/categories/presentation/categories_screen.dart';
import 'package:personal_finance_manager/features/receipt_scanner/application/ai_receipt_vision_service.dart';
import 'package:personal_finance_manager/features/receipt_scanner/application/ocr_parser_service.dart';
import 'package:personal_finance_manager/features/reports/presentation/reports_screen.dart';
import 'package:personal_finance_manager/features/settings/presentation/settings_screen.dart';
import 'package:personal_finance_manager/features/transactions/presentation/transaction_form_sheet.dart';

class _InMemorySecureStorage extends SecureStorageService {
  _InMemorySecureStorage() : super(inMemory: true);

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
  Future<void> clearLastEmail() async =>
      _store.remove('last_authenticated_email');

  @override
  Future<void> saveAiApiKeys({
    required String geminiKey,
    required String groqKey,
  }) async {
    if (geminiKey.trim().isEmpty) {
      _store.remove('ai_gemini_api_key');
    } else {
      _store['ai_gemini_api_key'] = geminiKey.trim();
    }
    if (groqKey.trim().isEmpty) {
      _store.remove('ai_groq_api_key');
    } else {
      _store['ai_groq_api_key'] = groqKey.trim();
    }
  }

  @override
  Future<String?> getGeminiApiKey() async => _store['ai_gemini_api_key'];

  @override
  Future<String?> getGroqApiKey() async => _store['ai_groq_api_key'];

  @override
  Future<void> clearSession() async {
    _store.remove('access_token');
    _store.remove('user_id');
    await clearLocalPasswordVerifier();
    await saveBiometricEnabled(false);
  }
}

class _StubBiometricAuthService extends BiometricAuthService {
  bool available = true;
  bool shouldSucceed = true;
  int authenticateCalls = 0;

  @override
  Future<bool> isBiometricAvailable() async => available;

  @override
  Future<bool> authenticate({required String reason}) async {
    authenticateCalls++;
    return shouldSucceed;
  }
}

Future<AppDatabase> _pumpAppWithMemoryDb(
  WidgetTester tester, {
  ApiClient? apiClient,
  SecureStorageService? secureStorage,
  BiometricAuthService? biometricService,
}) async {
  final db = AppDatabase(NativeDatabase.memory());
  final storage = secureStorage ?? _InMemorySecureStorage();
  final biometric = biometricService ?? _StubBiometricAuthService();
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      secureStorageServiceProvider.overrideWithValue(storage),
      biometricAuthServiceProvider.overrideWithValue(biometric),
      if (apiClient != null) apiClientProvider.overrideWithValue(apiClient),
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
      expect(
        parser.recommendCategoryKeyword(
          decimalComma.rawText,
          decimalComma.merchantName,
        ),
        'kesehatan',
      );

      final splitTotalReceipt = parser.parseReceiptText(
        'WARUNG KOPI NUSANTARA\n'
        '21 Nov 2026\n'
        'Kopi Tubruk  15.000\n'
        'Pisang Bakar  30.000\n'
        'TOTAL BAYAR\n'
        'Rp 45.000',
      );
      expect(splitTotalReceipt.merchantName, 'WARUNG KOPI NUSANTARA');
      expect(splitTotalReceipt.detectedAmount, 45000);
      expect(splitTotalReceipt.detectedDate, DateTime(2026, 11, 21));
      expect(
        parser.recommendCategoryKeyword(
          splitTotalReceipt.rawText,
          splitTotalReceipt.merchantName,
        ),
        'makan',
      );
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

        await tester.tap(
          find.descendant(
            of: find.byType(TransactionFormSheet),
            matching: find.text('Pemasukan'),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nominal (Rp)'),
          '3000000',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Deskripsi'),
          'Gaji Pokok',
        );
        await tester.ensureVisible(find.text('Simpan Pemasukan'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Simpan Pemasukan'));
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
        await tester.ensureVisible(find.text('Simpan Pengeluaran'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Simpan Pengeluaran'));
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
        await tester.ensureVisible(find.text('Simpan Perubahan'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Simpan Perubahan'));
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

        await tester.tap(find.text('Ambil Ulang'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Input Teks Struk Manual'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama File Struk (Kamera/Galeri)'),
          'struk_minimarket.jpg',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Teks Hasil OCR Struk'),
          'INDOMARET SUDIRMAN\n21/11/2026\nAir Mineral 4.500\nTOTAL Rp 35.000',
        );
        await tester.ensureVisible(find.text('Ekstrak & Deteksi Nominal OCR'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ekstrak & Deteksi Nominal OCR'));
        await tester.pumpAndSettle();

        expect(find.text('INDOMARET SUDIRMAN'), findsWidgets);
        expect(find.text('35.000'), findsWidgets);

        final saveBtn = find.text('Simpan Transaksi Pengeluaran');
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

    testWidgets(
      'Categories UI displays Stitch tabs, search, custom icon/color creation, and active switch',
      timeout: const Timeout(Duration(seconds: 30)),
      (tester) async {
        final db = await _pumpAppWithMemoryDb(tester);

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        final settingsScrollable = find.descendant(
          of: find.byType(SettingsScreen),
          matching: find.byType(Scrollable),
        ).first;
        await tester.scrollUntilVisible(
          find.text('Kelola Kategori'),
          200,
          scrollable: settingsScrollable,
        );
        Scrollable.ensureVisible(
          tester.element(find.text('Kelola Kategori')),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Kelola Kategori'));
        await tester.pumpAndSettle();

        expect(find.text('Kelola Kategori Transaksi'), findsOneWidget);
        expect(find.text('Makanan'), findsOneWidget);

        // Switch segmented tab to Pemasukan -> Gaji appears
        await tester.tap(find.text('Pemasukan').first);
        await tester.pumpAndSettle();
        expect(find.text('Gaji'), findsOneWidget);

        // Switch back to Pengeluaran and open CategoryFormSheet
        await tester.tap(find.text('Pengeluaran').first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tambah Kategori Baru'));
        await tester.pumpAndSettle();
        expect(find.byType(CategoryFormSheet), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Kategori'),
          'Ngopi & Kafe',
        );
        await tester.enterText(
          find.widgetWithText(
            TextFormField,
            'Deskripsi / Sub-catatan (Opsional)',
          ),
          'Ngopi sore santai',
        );
        await tester.tap(find.text('Simpan Kategori'));
        await tester.pumpAndSettle();

        final categories = await db.select(db.localCategories).get();
        final created =
            categories.where((c) => c.name == 'Ngopi & Kafe').toList();
        expect(created.length, 1);
        expect(created.first.color, '#D97706');
        expect(created.first.icon, 'local_cafe|Ngopi sore santai');

        // Search filters down to the newly created category and toggle switch works
        await tester.enterText(
          find.widgetWithText(TextField, 'Cari nama kategori...'),
          'Ngopi',
        );
        await tester.pumpAndSettle();
        expect(find.text('Ngopi & Kafe'), findsOneWidget);

        await tester.tap(find.bySemanticsLabel('Nonaktifkan Ngopi & Kafe'));
        await tester.pumpAndSettle();
        expect(find.text('Nonaktif'), findsOneWidget);
      },
    );

    test('AiReceiptVisionService parses Gemini clean JSON & Groq markdown JSON', () {
      final geminiRaw = jsonEncode({
        'merchant_name': 'ALFAMART DIPONEGORO',
        'total_amount': 'Rp 54.500,00',
        'transaction_date': '2026-11-22 10:15:00',
        'suggested_category': 'Belanja',
        'line_items': ['Susu UHT 18.500', 'Roti Tawar 36.000'],
        'raw_text': 'ALFAMART DIPONEGORO\nTOTAL 54.500',
      });

      final geminiParsed = AiReceiptVisionService.parseAiJsonPayload(
        geminiRaw,
        providerLabel: 'AI Gemini Flash Lite',
      );
      expect(geminiParsed, isNotNull);
      expect(geminiParsed!.merchantName, 'ALFAMART DIPONEGORO');
      expect(geminiParsed.detectedAmount, 54500);
      expect(geminiParsed.suggestedCategory, 'Belanja');
      expect(geminiParsed.detectedDate, DateTime(2026, 11, 22, 10, 15));
      expect(geminiParsed.lineItems.length, 2);
      expect(geminiParsed.fallbackUsed, isFalse);

      const groqRaw = '''
Hasil pembacaan nota:
```json
{
  "merchant_name": "WARUNG BAKSO MAS",
  "total_amount": 48000,
  "transaction_date": "22/11/2026 12:30",
  "suggested_category": "Makanan",
  "line_items": ["Bakso Urat 25.000", "Es Teh 23.000"]
}
```''';
      final groqParsed = AiReceiptVisionService.parseAiJsonPayload(
        groqRaw,
        providerLabel: 'Groq Fallback • Qwen 3.8 Vision',
        fallbackUsed: true,
      );
      expect(groqParsed, isNotNull);
      expect(groqParsed!.merchantName, 'WARUNG BAKSO MAS');
      expect(groqParsed.detectedAmount, 48000);
      expect(groqParsed.detectedDate, DateTime(2026, 11, 22, 12, 30));
      expect(groqParsed.suggestedCategory, 'Makanan');
      expect(groqParsed.fallbackUsed, isTrue);
    });

    test('AiReceiptVisionService automatically falls back from Gemini 429 to Groq Vision', () async {
      final storage = _InMemorySecureStorage();
      await storage.saveAiApiKeys(
        geminiKey: 'gem-key-123',
        groqKey: 'gsk-key-456',
      );

      final env = const EnvConfig(
        environment: AppEnvironment.prod,
        apiBaseUrl: EnvConfig.productionBaseUrl,
      );

      final adapter = _StubAiFallbackAdapter();
      final mockExternalDio = Dio()..httpClientAdapter = adapter;
      final service = AiReceiptVisionService(
        envConfig: env,
        secureStorage: storage,
        apiClient: ApiClient(envConfig: env, secureStorage: storage),
        externalDio: mockExternalDio,
      );

      final tempBytes = Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);

      final outcome = await service.scanReceiptBytes(
        bytes: tempBytes,
        fileNameHint: 'struk.jpg',
        categoryNames: const ['Makanan', 'Belanja', 'Kesehatan'],
        isCloudAuthenticated: false,
      );

      expect(adapter.calledHosts, [
        'generativelanguage.googleapis.com',
        'api.groq.com',
      ]);
      expect(outcome.hasExtraction, isTrue);
      expect(outcome.providerCode, 'groq');
      expect(outcome.fallbackUsed, isTrue);
      expect(outcome.result!.merchantName, 'SATE SENAYAN');
      expect(outcome.result!.detectedAmount, 92000);
      expect(outcome.result!.suggestedCategory, 'Makanan');
    });

    testWidgets(
      'AuthScreen supports Login, Register with email OTP (without name), and 3-step Forgot Password flow',
      timeout: const Timeout(Duration(seconds: 30)),
      (tester) async {
        final storage = _InMemorySecureStorage();
        final authAdapter = _StubAuthAdapter();
        const env = EnvConfig(
          environment: AppEnvironment.prod,
          apiBaseUrl: EnvConfig.productionBaseUrl,
        );
        final mockDio = Dio(
          BaseOptions(
            baseUrl: env.apiBaseUrl,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        )..httpClientAdapter = authAdapter;
        final stubApiClient = ApiClient(
          envConfig: env,
          secureStorage: storage,
          dio: mockDio,
        );

        await _pumpAppWithMemoryDb(
          tester,
          apiClient: stubApiClient,
          secureStorage: storage,
        );

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Masuk atau Daftar Akun Cloud'));
        await tester.pumpAndSettle();
        expect(find.byType(AuthScreen), findsOneWidget);

        // 1. Register Tab: Email + Password + Confirm + 6-digit Email OTP (no Nama Lengkap)
        final goRegisterBtn = find.text('Daftar Akun Baru');
        await tester.ensureVisible(goRegisterBtn);
        await tester.pumpAndSettle();
        await tester.tap(goRegisterBtn);
        await tester.pumpAndSettle();
        expect(find.text('Nama Lengkap'), findsNothing);
        expect(find.text('Mulai Kelola Finansial Anda'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'budi@example.com',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Kata Sandi'),
          'PassBaru123!',
        );
        await tester.pumpAndSettle();
        expect(find.text('Kekuatan Sandi'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Konfirmasi Kata Sandi'),
          'PassBaru123!',
        );
        await tester.pumpAndSettle();
        expect(find.text('Kata sandi cocok'), findsOneWidget);

        final sendOtpBtn = find.text('Kirim OTP');
        await tester.ensureVisible(sendOtpBtn);
        await tester.pumpAndSettle();
        await tester.tap(sendOtpBtn);
        await tester.pumpAndSettle();

        expect(authAdapter.sentRegisterOtpEmail, 'budi@example.com');
        expect(
          find.textContaining('Kode OTP terkirim ke budi@example.com'),
          findsOneWidget,
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Kode OTP Email (6 digit)'),
          '654321',
        );
        final termsCheckbox = find.byKey(const Key('register_terms_checkbox'));
        await tester.ensureVisible(termsCheckbox);
        await tester.pumpAndSettle();
        await tester.tap(termsCheckbox);
        await tester.pumpAndSettle();

        final registerBtn = find.text('Daftar Akun Sekarang');
        await tester.ensureVisible(registerBtn);
        await tester.pumpAndSettle();
        await tester.tap(registerBtn);
        await tester.pumpAndSettle();

        expect(authAdapter.registeredOtpCode, '654321');
        expect(find.text('Akun Cloud Terhubung'), findsOneWidget);
        expect(find.text('budi@example.com'), findsOneWidget);

        // Logout so we can test 3-step Forgot Password & Login
        await tester.tap(find.text('Keluar dari Akun Cloud'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Masuk atau Daftar Akun Cloud'));
        await tester.pumpAndSettle();

        // 2. Forgot Password 3-step flow: Email -> OTP -> New Password
        final forgotLink = find.text('Lupa Password?');
        await tester.ensureVisible(forgotLink);
        await tester.pumpAndSettle();
        await tester.tap(forgotLink);
        await tester.pumpAndSettle();

        expect(find.text('1. Email'), findsOneWidget);
        expect(find.text('2. Kode OTP'), findsOneWidget);
        expect(find.text('3. Sandi Baru'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'budi@example.com',
        );
        await tester.pumpAndSettle();
        expect(find.text('Format Valid'), findsOneWidget);

        final sendResetOtpBtn = find.text('Kirim Kode Verifikasi (OTP)');
        await tester.ensureVisible(sendResetOtpBtn);
        await tester.pumpAndSettle();
        await tester.tap(sendResetOtpBtn);
        await tester.pumpAndSettle();

        expect(authAdapter.sentResetOtpEmail, 'budi@example.com');
        expect(find.text('Email Tujuan OTP'), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('forgot_otp_field')),
          '112233',
        );
        final verifyOtpBtn = find.text('Verifikasi Kode OTP');
        await tester.ensureVisible(verifyOtpBtn);
        await tester.pumpAndSettle();
        await tester.tap(verifyOtpBtn);
        await tester.pumpAndSettle();

        expect(authAdapter.verifiedResetOtpCode, '112233');
        expect(
          find.text('OTP terverifikasi untuk budi@example.com.'),
          findsOneWidget,
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Kata Sandi Baru'),
          'PassBaru999!',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Konfirmasi Kata Sandi Baru'),
          'PassBaru999!',
        );
        final saveNewPassBtn = find.text('Simpan Kata Sandi Baru');
        await tester.ensureVisible(saveNewPassBtn);
        await tester.pumpAndSettle();
        await tester.tap(saveNewPassBtn);
        await tester.pumpAndSettle();

        expect(authAdapter.resetNewPassword, 'PassBaru999!');

        // 3. Returned automatically to Login tab -> sign in with new password
        await tester.enterText(
          find.byKey(const Key('auth_password_field')),
          'PassBaru999!',
        );
        final loginBtn = find.text('Masuk Sekarang');
        await tester.ensureVisible(loginBtn);
        await tester.pumpAndSettle();
        await tester.tap(loginBtn);
        await tester.pumpAndSettle();

        expect(authAdapter.loggedInEmail, 'budi@example.com');
        expect(find.text('Akun Cloud Terhubung'), findsOneWidget);
      },
    );

    testWidgets(
      'Biometric quick login requires first-time email+password, activates in Settings, and locks app on reopen',
      timeout: const Timeout(Duration(seconds: 30)),
      (tester) async {
        final db = AppDatabase(NativeDatabase.memory());
        final storage = _InMemorySecureStorage();
        final biometricStub = _StubBiometricAuthService();
        final authAdapter = _StubAuthAdapter();
        const env = EnvConfig(
          environment: AppEnvironment.prod,
          apiBaseUrl: EnvConfig.productionBaseUrl,
        );
        final mockDio = Dio(
          BaseOptions(
            baseUrl: env.apiBaseUrl,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        )..httpClientAdapter = authAdapter;
        final stubApiClient = ApiClient(
          envConfig: env,
          secureStorage: storage,
          dio: mockDio,
        );

        ProviderContainer makeContainer() {
          return ProviderContainer(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              secureStorageServiceProvider.overrideWithValue(storage),
              biometricAuthServiceProvider.overrideWithValue(biometricStub),
              apiClientProvider.overrideWithValue(stubApiClient),
              backendHealthProvider.overrideWith(
                (ref) async => {
                  'status': 'ok',
                  'version': 'v1',
                  'database': 'connected',
                },
              ),
            ],
          );
        }

        var activeContainer = makeContainer();
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));
          activeContainer.dispose();
          await tester.runAsync(() => db.close());
          await tester.pump(const Duration(milliseconds: 50));
        });

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: activeContainer,
            child: const PersonalFinanceApp(),
          ),
        );
        await tester.pumpAndSettle();

        // First-time user cannot enable fingerprint in Settings before login
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        final bioSwitchBeforeLogin = tester.widget<SwitchListTile>(
          find.byKey(const Key('biometric_toggle_switch')),
        );
        expect(bioSwitchBeforeLogin.onChanged, isNull);

        await tester.tap(find.text('Masuk atau Daftar Akun Cloud'));
        await tester.pumpAndSettle();

        // Tapping fingerprint on first-time login must show guidance and not unlock
        final firstBioBtn = find.byKey(const Key('biometric_login_button'));
        await tester.ensureVisible(firstBioBtn);
        await tester.pumpAndSettle();
        await tester.tap(firstBioBtn);
        await tester.pumpAndSettle();
        expect(biometricStub.authenticateCalls, 0);
        expect(
          find.textContaining('masuk pertama kali wajib menggunakan email'),
          findsOneWidget,
        );

        // Log in with Email + Password
        await tester.enterText(
          find.byKey(const Key('auth_email_field')),
          'budi@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('auth_password_field')),
          'PassBaru999!',
        );
        final loginBtn = find.text('Masuk Sekarang');
        await tester.ensureVisible(loginBtn);
        await tester.pumpAndSettle();
        await tester.tap(loginBtn);
        await tester.pumpAndSettle();

        expect(find.text('Akun Cloud Terhubung'), findsOneWidget);

        // Activate fingerprint login in Settings
        final bioSwitch = find.byKey(const Key('biometric_toggle_switch'));
        await tester.ensureVisible(bioSwitch);
        await tester.pumpAndSettle();
        await tester.tap(bioSwitch);
        await tester.pumpAndSettle();

        expect(biometricStub.authenticateCalls, 1);
        expect(
          find.textContaining('Aktif • Gunakan sidik jari'),
          findsOneWidget,
        );

        // Simulate closing & reopening the app (fresh ProviderContainer)
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        activeContainer.dispose();

        activeContainer = makeContainer();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: activeContainer,
            child: const PersonalFinanceApp(),
          ),
        );
        await tester.pumpAndSettle();

        // App must be locked on Stitch Login with saved email prefilled
        expect(find.text('TOTAL SALDO AKTIF (1 REKENING)'), findsNothing);
        expect(find.byType(AuthScreen), findsOneWidget);
        expect(find.text('Akses Terkunci'), findsOneWidget);
        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('auth_email_field')))
              .controller
              ?.text,
          'budi@example.com',
        );

        // Unlock using Fingerprint
        final lockBioBtn = find.byKey(const Key('biometric_login_button'));
        await tester.ensureVisible(lockBioBtn);
        await tester.pumpAndSettle();
        await tester.tap(lockBioBtn);
        await tester.pumpAndSettle();

        expect(biometricStub.authenticateCalls, 2);
        expect(find.byType(AuthScreen), findsNothing);
        expect(find.textContaining('TOTAL SALDO AKTIF'), findsOneWidget);

        // Manual lock from Settings -> test offline password unlock fallback
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        final lockNowTile = find.text('Kunci Aplikasi Sekarang');
        await tester.ensureVisible(lockNowTile);
        await tester.pumpAndSettle();
        await tester.tap(lockNowTile);
        await tester.pumpAndSettle();

        expect(find.byType(AuthScreen), findsOneWidget);
        authAdapter.simulateOffline = true;

        // Wrong offline password must be rejected
        await tester.enterText(
          find.byKey(const Key('auth_password_field')),
          'SalahPassword123',
        );
        final unlockBtn = find.text('Masuk Sekarang');
        await tester.ensureVisible(unlockBtn);
        await tester.pumpAndSettle();
        await tester.tap(unlockBtn);
        await tester.pumpAndSettle();
        expect(find.textContaining('Kata sandi salah'), findsOneWidget);
        expect(find.byType(AuthScreen), findsOneWidget);

        // Correct password unlocks even offline via salted verifier
        await tester.enterText(
          find.byKey(const Key('auth_password_field')),
          'PassBaru999!',
        );
        await tester.ensureVisible(unlockBtn);
        await tester.pumpAndSettle();
        await tester.tap(unlockBtn);
        await tester.pumpAndSettle();

        expect(find.byType(AuthScreen), findsNothing);
        expect(find.text('Akun Cloud Terhubung'), findsOneWidget);
      },
    );
  });
}

class _StubAuthAdapter implements HttpClientAdapter {
  bool simulateOffline = false;
  String? sentRegisterOtpEmail;
  String? registeredOtpCode;
  String? sentResetOtpEmail;
  String? verifiedResetOtpCode;
  String? resetNewPassword;
  String? loggedInEmail;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (simulateOffline) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        message: 'Simulated offline network outage',
      );
    }
    final path = options.uri.path;
    final body = options.data is Map
        ? Map<String, dynamic>.from(options.data as Map)
        : <String, dynamic>{};

    ResponseBody jsonRes(int status, Map<String, dynamic> payload) {
      return ResponseBody.fromString(
        jsonEncode(payload),
        status,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    if (path.endsWith('/auth/register/send-otp')) {
      sentRegisterOtpEmail = body['email']?.toString();
      return jsonRes(200, {
        'success': true,
        'message': 'Kode OTP telah dikirim ke email Anda.',
        'data': {
          'email': sentRegisterOtpEmail,
          'expires_in_seconds': 600,
          'resend_cooldown_seconds': 60,
        },
      });
    }

    if (path.endsWith('/auth/register')) {
      registeredOtpCode = body['otp_code']?.toString();
      return jsonRes(201, {
        'success': true,
        'message': 'Registration successful',
        'data': {
          'user': {
            'id': 'user-budi-001',
            'name': 'Budi',
            'email': body['email'] ?? 'budi@example.com',
          },
          'settings': {
            'id': 'set-001',
            'theme_mode': 'system',
            'currency': 'IDR',
            'timezone': 'Asia/Jakarta',
            'budget_warning_percent': 80,
          },
          'access_token': 'tok-register-001',
          'token_type': 'Bearer',
          'sync_meta': {'last_sequence': 0, 'device_cursor': 0},
        },
      });
    }

    if (path.endsWith('/auth/password/send-otp')) {
      sentResetOtpEmail = body['email']?.toString();
      return jsonRes(200, {
        'success': true,
        'message': 'Kode OTP reset kata sandi telah dikirim ke email Anda.',
        'data': {
          'email': sentResetOtpEmail,
          'expires_in_seconds': 600,
          'resend_cooldown_seconds': 60,
        },
      });
    }

    if (path.endsWith('/auth/password/verify-otp')) {
      verifiedResetOtpCode = body['otp_code']?.toString();
      return jsonRes(200, {
        'success': true,
        'message': 'Kode OTP terverifikasi.',
        'data': {
          'email': body['email'],
          'verified': true,
        },
      });
    }

    if (path.endsWith('/auth/password/reset')) {
      resetNewPassword = body['password']?.toString();
      return jsonRes(200, {
        'success': true,
        'message': 'Kata sandi berhasil diperbarui.',
        'data': {'email': body['email']},
      });
    }

    if (path.endsWith('/auth/login')) {
      loggedInEmail = body['email']?.toString();
      return jsonRes(200, {
        'success': true,
        'message': 'Login successful',
        'data': {
          'user': {
            'id': 'user-budi-001',
            'name': 'Budi',
            'email': loggedInEmail ?? 'budi@example.com',
          },
          'access_token': 'tok-login-001',
          'token_type': 'Bearer',
          'sync_meta': {'last_sequence': 0, 'device_cursor': 0},
        },
      });
    }

    if (path.endsWith('/auth/logout')) {
      return jsonRes(200, {'success': true, 'message': 'Logout successful'});
    }

    if (path.endsWith('/sync/pull')) {
      return jsonRes(200, {
        'success': true,
        'data': {
          'changes': <dynamic>[],
          'next_cursor': 0,
          'has_more': false,
        },
      });
    }

    return jsonRes(404, {'success': false, 'message': 'Not mocked: $path'});
  }
}

class _StubAiFallbackAdapter implements HttpClientAdapter {
  final List<String> calledHosts = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calledHosts.add(options.uri.host);
    if (options.uri.host.contains('googleapis.com')) {
      return ResponseBody.fromString(
        jsonEncode({
          'error': {'message': 'Quota exceeded'},
        }),
        429,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    return ResponseBody.fromString(
      jsonEncode({
        'choices': [
          {
            'message': {
              'content': jsonEncode({
                'merchant_name': 'SATE SENAYAN',
                'total_amount': 92000,
                'transaction_date': '2026-11-22 13:00:00',
                'suggested_category': 'Makanan',
                'line_items': ['Sate Ayam 65.000', 'Lontong & Minum 27.000'],
                'raw_text': 'SATE SENAYAN\nTOTAL 92.000',
              }),
            },
          },
        ],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}
