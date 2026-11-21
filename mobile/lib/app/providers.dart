import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/config/env_config.dart';
import '../core/database/app_database.dart';
import '../core/network/api_client.dart';
import '../core/security/secure_storage_service.dart';

final envConfigProvider = Provider<EnvConfig>((ref) {
  return EnvConfig.fromEnvironment();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    envConfig: ref.watch(envConfigProvider),
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

final localDbHealthProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.checkDatabaseHealth();
});

final backendHealthProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.checkHealth();
  return response.data ?? const {};
});

