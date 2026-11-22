import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({
    FlutterSecureStorage? storage,
    this.inMemory = false,
  }) : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  static const _keyAccessToken = 'access_token';
  static const _keyUserId = 'user_id';
  static const _keyDeviceId = 'device_id';
  static const _keyLastEmail = 'last_authenticated_email';
  static const _keyBiometricEnabled = 'biometric_login_enabled';
  static const _keyRememberEmail = 'remember_login_email';
  static const _keyLocalPasswordVerifier = 'local_password_verifier';
  static const _keyGeminiApiKey = 'ai_gemini_api_key';
  static const _keyGroqApiKey = 'ai_groq_api_key';

  final FlutterSecureStorage _storage;
  final bool inMemory;
  final Map<String, String> _runtimeFallback = {};

  Future<void> _writeSafe(String key, String value) async {
    _runtimeFallback[key] = value;
    if (inMemory) return;
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // Safe fallback in headless tests without FlutterSecureStorage plugin.
    }
  }

  Future<String?> _readSafe(String key) async {
    if (inMemory) return _runtimeFallback[key];
    try {
      final val = await _storage.read(key: key);
      if (val != null) return val;
    } catch (_) {
      return _runtimeFallback[key];
    }
    return _runtimeFallback[key];
  }

  Future<void> _deleteSafe(String key) async {
    _runtimeFallback.remove(key);
    if (inMemory) return;
    try {
      await _storage.delete(key: key);
    } catch (_) {
      // Safe fallback in headless tests without FlutterSecureStorage plugin.
    }
  }

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

  Future<String?> getLastEmail() => _readSafe(_keyLastEmail);

  Future<void> clearLastEmail() => _deleteSafe(_keyLastEmail);

  Future<void> saveBiometricEnabled(bool enabled) =>
      _writeSafe(_keyBiometricEnabled, enabled ? 'true' : 'false');

  Future<bool> isBiometricEnabled() async {
    final val = await _readSafe(_keyBiometricEnabled);
    return val == 'true';
  }

  Future<void> saveRememberEmail(bool remember) =>
      _writeSafe(_keyRememberEmail, remember ? 'true' : 'false');

  Future<bool> isRememberEmailEnabled() async {
    final val = await _readSafe(_keyRememberEmail);
    if (val == null) return true;
    return val == 'true';
  }

  Future<void> saveLocalPasswordVerifier({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final rng = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => rng.nextInt(256));
    final saltB64 = base64UrlEncode(saltBytes);
    final digestHex = _stretchSha256Hex(
      saltB64: saltB64,
      normalizedEmail: normalizedEmail,
      password: password,
    );
    await _writeSafe(
      _keyLocalPasswordVerifier,
      '$normalizedEmail|$saltB64|$digestHex',
    );
  }

  Future<bool> verifyLocalPassword({
    required String email,
    required String password,
  }) async {
    final stored = await _readSafe(_keyLocalPasswordVerifier);
    if (stored == null || stored.isEmpty) return false;
    final parts = stored.split('|');
    if (parts.length != 3) return false;

    final storedEmail = parts[0];
    final saltB64 = parts[1];
    final storedDigest = parts[2];
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail != storedEmail) return false;

    final candidateDigest = _stretchSha256Hex(
      saltB64: saltB64,
      normalizedEmail: normalizedEmail,
      password: password,
    );
    return _constantTimeEquals(storedDigest, candidateDigest);
  }

  Future<void> clearLocalPasswordVerifier() =>
      _deleteSafe(_keyLocalPasswordVerifier);

  static String _stretchSha256Hex({
    required String saltB64,
    required String normalizedEmail,
    required String password,
  }) {
    List<int> digest = utf8.encode('$saltB64|$normalizedEmail|$password');
    for (var i = 0; i < 10000; i++) {
      digest = sha256.convert(digest).bytes;
    }
    final buffer = StringBuffer();
    for (final byte in digest) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

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
      _deleteSafe(_keyAccessToken),
      _deleteSafe(_keyUserId),
      _deleteSafe(_keyLocalPasswordVerifier),
      _deleteSafe(_keyBiometricEnabled),
    ]);
    if (!await isRememberEmailEnabled()) {
      await clearLastEmail();
    }
  }
}

