import 'package:shared_preferences/shared_preferences.dart';

class DBService {
  static late SharedPreferences _prefs;

  /// Inisialisasi SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Menyimpan String
  static Future<void> set(String key, String value) async {
    await _prefs.setString(key, value);
  }

  /// Menyimpan Integer
  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  /// Menyimpan Boolean
  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  /// Mengambil String
  static String? get(String key) {
    return _prefs.getString(key);
  }

  /// Mengambil Integer
  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Mengambil Boolean
  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Hapus 1 key
  static Future<void> clear(String key) async {
    await _prefs.remove(key);
  }

  /// Bersihkan semua data (opsional)
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
