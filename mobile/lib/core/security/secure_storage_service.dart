import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  static const _keyAccessToken = 'access_token';
  static const _keyUserId = 'user_id';
  static const _keyDeviceId = 'device_id';
  static const _keyLastEmail = 'last_authenticated_email';

  final FlutterSecureStorage _storage;

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);

  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);

  Future<void> saveSessionMetadata({
    required String userId,
    required String deviceId,
    required String email,
  }) async {
    await Future.wait([
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyDeviceId, value: deviceId),
      _storage.write(key: _keyLastEmail, value: email),
    ]);
  }

  Future<String?> getUserId() => _storage.read(key: _keyUserId);

  Future<String?> getDeviceId() => _storage.read(key: _keyDeviceId);

  Future<String?> getLastEmail() => _storage.read(key: _keyLastEmail);

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyUserId),
    ]);
  }
}

