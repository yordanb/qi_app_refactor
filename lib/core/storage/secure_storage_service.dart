import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper untuk menyimpan data sensitif (token, credentials)
/// Menggunakan Singleton pattern - hanya satu instance yang ada
class SecureStorageService {
  final FlutterSecureStorage _storage;

  // Private constructor untuk singleton
  SecureStorageService._()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            // encryptedSharedPreferences deprecated, automatically handled by package
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  // Singleton instance
  static final SecureStorageService _instance = SecureStorageService._();
  factory SecureStorageService() => _instance;

  /// Simpan string value
  Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Ambil string value
  Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  /// Hapus single key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Hapus semua data
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Cek apakah key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Convenience methods untuk token management
  Future<void> setToken(String token) => setString('token', token);
  Future<void> setRefreshToken(String refreshToken) =>
      setString('refresh_token', refreshToken);
  Future<void> setNRP(String nrp) => setString('nrp', nrp);
  Future<void> setRole(String role) => setString('role', role);
  Future<void> setExpiredAt(String expiredAt) =>
      setString('expired_at', expiredAt);

  Future<String?> getToken() => getString('token');
  Future<String?> getRefreshToken() => getString('refresh_token');
  Future<String?> getNRP() => getString('nrp');
  Future<String?> getRole() => getString('role');
  Future<String?> getExpiredAt() => getString('expired_at');

  /// Clear semua authentication data
  Future<void> clearAuth() async {
    await Future.wait([
      delete('token'),
      delete('refresh_token'),
      delete('nrp'),
      delete('role'),
      delete('expired_at'),
    ]);
  }
}
