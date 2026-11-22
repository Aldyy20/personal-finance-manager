import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/sync/sync_manager.dart';

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.deviceId,
    required this.email,
    required this.accessToken,
  });

  final String userId;
  final String deviceId;
  final String email;
  final String accessToken;
}

class AuthRepository {
  AuthRepository({
    required this.db,
    required this.apiClient,
    required this.secureStorage,
    required this.syncManager,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase db;
  final ApiClient apiClient;
  final SecureStorageService secureStorage;
  final SyncManager syncManager;
  final Uuid _uuid;

  Future<String> ensureDeviceId() async {
    final existing = await secureStorage.getDeviceId();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    return _uuid.v4();
  }

  Future<({int expiresInSeconds, int resendCooldownSeconds})> sendRegisterOtp({
    required String email,
  }) async {
    final res = await apiClient.post<Map<String, dynamic>>(
      '/auth/register/send-otp',
      data: {'email': email},
      parseData: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final data = res.data ?? const {};
    return (
      expiresInSeconds: (data['expires_in_seconds'] as num?)?.toInt() ?? 600,
      resendCooldownSeconds:
          (data['resend_cooldown_seconds'] as num?)?.toInt() ?? 60,
    );
  }

  Future<({int expiresInSeconds, int resendCooldownSeconds})>
      sendPasswordResetOtp({
    required String email,
  }) async {
    final res = await apiClient.post<Map<String, dynamic>>(
      '/auth/password/send-otp',
      data: {'email': email},
      parseData: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final data = res.data ?? const {};
    return (
      expiresInSeconds: (data['expires_in_seconds'] as num?)?.toInt() ?? 600,
      resendCooldownSeconds:
          (data['resend_cooldown_seconds'] as num?)?.toInt() ?? 60,
    );
  }

  Future<void> verifyPasswordResetOtp({
    required String email,
    required String otpCode,
  }) async {
    await apiClient.post<dynamic>(
      '/auth/password/verify-otp',
      data: {
        'email': email,
        'otp_code': otpCode,
      },
    );
  }

  Future<void> resetPasswordWithOtp({
    required String email,
    required String otpCode,
    required String password,
    required String passwordConfirmation,
  }) async {
    await apiClient.post<dynamic>(
      '/auth/password/reset',
      data: {
        'email': email,
        'otp_code': otpCode,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<AuthSession> register({
    String? name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String otpCode = '',
    String deviceName = 'Android Device',
    bool pullInitialData = true,
  }) async {
    final deviceId = await ensureDeviceId();

    final payload = <String, dynamic>{
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'otp_code': otpCode,
      'device': {
        'id': deviceId,
        'name': deviceName,
        'platform': 'android',
        'app_version': '1.0.0',
      },
    };
    final trimmedName = name?.trim() ?? '';
    if (trimmedName.isNotEmpty) {
      payload['name'] = trimmedName;
    }

    final res = await apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: payload,
      parseData: (raw) => Map<String, dynamic>.from(raw as Map),
    );

    final data = res.data!;
    return _persistAuthenticatedSession(data, deviceId, pullInitialData: pullInitialData);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
    String deviceName = 'Android Device',
    bool pullInitialData = true,
  }) async {
    final deviceId = await ensureDeviceId();

    final res = await apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        'device': {
          'id': deviceId,
          'name': deviceName,
          'platform': 'android',
          'app_version': '1.0.0',
        },
      },
      parseData: (raw) => Map<String, dynamic>.from(raw as Map),
    );

    final data = res.data!;
    return _persistAuthenticatedSession(data, deviceId, pullInitialData: pullInitialData);
  }

  Future<void> logout() async {
    try {
      await apiClient.post<Map<String, dynamic>>('/auth/logout');
    } catch (_) {
      // Allow local logout even while offline
    }
    await secureStorage.clearSession();
  }

  Future<AuthSession?> getOfflineSession() async {
    final userId = await secureStorage.getUserId();
    final deviceId = await secureStorage.getDeviceId();
    final email = await secureStorage.getLastEmail();
    final token = await secureStorage.getAccessToken();

    if (userId == null || deviceId == null || token == null || email == null) {
      return null;
    }

    return AuthSession(
      userId: userId,
      deviceId: deviceId,
      email: email,
      accessToken: token,
    );
  }

  Future<AuthSession> _persistAuthenticatedSession(
    Map<String, dynamic> data,
    String deviceId, {
    required bool pullInitialData,
  }) async {
    final userMap = Map<String, dynamic>.from(data['user'] as Map);
    final userId = userMap['id'] as String;
    final userEmail = userMap['email'] as String;
    final token = data['access_token'] as String;

    // Prevent cross-account leakage when switching accounts on the same device
    final previousUserId = await secureStorage.getUserId();
    final hasOfflineGuest = await (db.select(db.localUsers)
          ..where((t) => t.id.equals('local-offline-user')))
        .getSingleOrNull();
    if ((previousUserId != null && previousUserId != userId) || hasOfflineGuest != null) {
      await _clearAllLocalTables();
    }

    await secureStorage.saveAccessToken(token);
    await secureStorage.saveSessionMetadata(
      userId: userId,
      deviceId: deviceId,
      email: userEmail,
    );

    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    await db.into(db.localUsers).insert(
          LocalUsersCompanion.insert(
            id: userId,
            name: userMap['name'] as String,
            email: userEmail,
            createdAtMs: nowMs,
            updatedAtMs: nowMs,
          ),
          mode: InsertMode.insertOrReplace,
        );

    if (pullInitialData) {
      await syncManager.pullServerChanges(userId: userId, deviceId: deviceId);
    }

    return AuthSession(
      userId: userId,
      deviceId: deviceId,
      email: userEmail,
      accessToken: token,
    );
  }

  Future<void> _clearAllLocalTables() async {
    await db.transaction(() async {
      for (final table in db.allTables) {
        await db.delete(table).go();
      }
    });
  }
}

