import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<String?> readAccess() => _storage.read(key: _accessKey);
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  // FCM Device Token persistence via FlutterSecureStorage
  static const _fcmTokenKey = 'fcm_device_token';
  Future<void> saveFcmToken(String token) =>
      _storage.write(key: _fcmTokenKey, value: token);
  Future<String?> readFcmToken() => _storage.read(key: _fcmTokenKey);
  Future<void> clearFcmToken() => _storage.delete(key: _fcmTokenKey);

  Future<void> clear() => _storage.deleteAll();
}