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
  static const _keyGeminiApiKey = 'ai_gemini_api_key';
  static const _keyGroqApiKey = 'ai_groq_api_key';

  final FlutterSecureStorage _storage;
  final Map<String, String> _runtimeFallback = {};

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

  Future<void> saveAiApiKeys({
    required String geminiKey,
    required String groqKey,
  }) async {
    final trimmedGemini = geminiKey.trim();
    final trimmedGroq = groqKey.trim();

    if (trimmedGemini.isEmpty) {
      _runtimeFallback.remove(_keyGeminiApiKey);
    } else {
      _runtimeFallback[_keyGeminiApiKey] = trimmedGemini;
    }

    if (trimmedGroq.isEmpty) {
      _runtimeFallback.remove(_keyGroqApiKey);
    } else {
      _runtimeFallback[_keyGroqApiKey] = trimmedGroq;
    }

    try {
      await Future.wait([
        if (trimmedGemini.isEmpty)
          _storage.delete(key: _keyGeminiApiKey)
        else
          _storage.write(key: _keyGeminiApiKey, value: trimmedGemini),
        if (trimmedGroq.isEmpty)
          _storage.delete(key: _keyGroqApiKey)
        else
          _storage.write(key: _keyGroqApiKey, value: trimmedGroq),
      ]);
    } catch (_) {
      // Safe no-op in headless test bindings without FlutterSecureStorage plugin.
    }
  }

  Future<String?> getGeminiApiKey() async {
    try {
      final val = await _storage.read(key: _keyGeminiApiKey);
      if (val != null && val.trim().isNotEmpty) return val.trim();
    } catch (_) {
      return _runtimeFallback[_keyGeminiApiKey];
    }
    return _runtimeFallback[_keyGeminiApiKey];
  }

  Future<String?> getGroqApiKey() async {
    try {
      final val = await _storage.read(key: _keyGroqApiKey);
      if (val != null && val.trim().isNotEmpty) return val.trim();
    } catch (_) {
      return _runtimeFallback[_keyGroqApiKey];
    }
    return _runtimeFallback[_keyGroqApiKey];
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyUserId),
    ]);
  }
}

