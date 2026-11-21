import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_finance_manager/app/app.dart';
import 'package:personal_finance_manager/app/providers.dart';
import 'package:personal_finance_manager/core/config/env_config.dart';
import 'package:personal_finance_manager/core/database/app_database.dart';
import 'package:personal_finance_manager/core/network/api_client.dart';
import 'package:personal_finance_manager/core/security/secure_storage_service.dart';
import 'package:personal_finance_manager/core/theme/app_theme.dart';
import 'package:personal_finance_manager/core/theme/financial_colors.dart';
import 'package:personal_finance_manager/core/utils/currency_formatter.dart';

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
  Future<String?> getDeviceId() async => _store['device_id'];

  @override
  Future<String?> getLastEmail() async => _store['last_authenticated_email'];

  @override
  Future<void> clearSession() async {
    _store.remove('access_token');
    _store.remove('user_id');
  }
}

void main() {
  group('Phase 1 Foundation Verification', () {
    test('Material Design 3 is active for Light and Dark themes', () {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;

      expect(light.useMaterial3, isTrue);
      expect(dark.useMaterial3, isTrue);
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.extension<FinancialColors>(), isNotNull);
      expect(dark.extension<FinancialColors>(), isNotNull);
    });

    test('Indonesian Rupiah formatter formats positive, zero, and negative amounts', () {
      expect(CurrencyFormatter.formatIdr(0), 'Rp0');
      expect(CurrencyFormatter.formatIdr(1500000), 'Rp1.500.000');
      expect(CurrencyFormatter.formatIdr(-50000), '-Rp50.000');
    });

    test('Drift SQLite database initializes, enforces foreign keys, and executes queries', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      expect(await db.checkDatabaseHealth(), isTrue);

      final fkResult = await db.customSelect('PRAGMA foreign_keys;').getSingle();
      expect(fkResult.read<int>('foreign_keys'), 1);

      await db.into(db.localSyncState).insert(
            LocalSyncStateCompanion.insert(
              id: 'state-1',
              userId: 'user-1',
              deviceId: 'device-1',
              lastCursor: const Value(42),
              updatedAtMs: 1700000000000,
            ),
          );

      final rows = await db.select(db.localSyncState).get();
      expect(rows.length, 1);
      expect(rows.first.lastCursor, 42);
    });

    testWidgets('App renders Material 3 NavigationBar with 5 tabs and FAB', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
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
          child: const PersonalFinanceApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Personal Finance Manager'), findsOneWidget);
      expect(find.text('Material Design 3: Active'), findsOneWidget);
      expect(find.text('Connected (SELECT 1 OK)'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    test('Dio ApiClient connects to running Laravel /api/v1/health endpoint', () async {
      const runLiveTest = bool.fromEnvironment('RUN_LIVE_API_TEST', defaultValue: false);
      if (!runLiveTest) {
        return;
      }

      // Allow real socket HTTP requests inside flutter test when verifying live backend.
      HttpOverrides.global = null;

      final client = ApiClient(
        envConfig: const EnvConfig(
          environment: AppEnvironment.dev,
          apiBaseUrl: 'http://127.0.0.1:8000/api/v1',
        ),
        secureStorage: _InMemorySecureStorage(),
      );

      final res = await client.checkHealth();
      expect(res.success, isTrue);
      expect(res.data, isNotNull);
      expect(res.data!['status'], 'ok');
      expect(res.data!['version'], 'v1');
      expect(res.data!['database'], 'connected');
    });
  });
}

