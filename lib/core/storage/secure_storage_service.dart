import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper untuk menyimpan data sensitif (token, credentials)
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // Android kelebih往事 encryption
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Simpan string value
  static Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Ambil string value
  static Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  /// Hapus single key
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Hapus semua data
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Cek apakah key exists
  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Convenience methods untuk token management
  static Future<void> setToken(String token) =>
      setString('token', token);
  static Future<void> setRefreshToken(String refreshToken) =>
      setString('refresh_token', refreshToken);
  static Future<void> setNRP(String nrp) =>
      setString('nrp', nrp);
  static Future<void> setRole(String role) =>
      setString('role', role);
  static Future<void> setExpiredAt(String expiredAt) =>
      setString('expired_at', expiredAt);

  static Future<String?> getToken() => getString('token');
  static Future<String?> getRefreshToken() => getString('refresh_token');
  static Future<String?> getNRP() => getString('nrp');
  static Future<String?> getRole() => getString('role');
  static Future<String?> getExpiredAt() => getString('expired_at');

  /// Clear所有 authentication data
  static Future<void> clearAuth() async {
    await Future.wait([
      delete('token'),
      delete('refresh_token'),
      delete('nrp'),
      delete('role'),
      delete('expired_at'),
    ]);
  }
}
