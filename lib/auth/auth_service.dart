import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:android_id/android_id.dart';

import 'db_service.dart';
import '../config/endpoints.dart';

class AuthService {
  /// Ambil Android ID
  Future<String?> getAndroidId() async {
    const androidIdPlugin = AndroidId();
    if (kDebugMode) {
      print(getAndroidId);
    }
    return await androidIdPlugin.getId();
  }

  /// Mengecek apakah Android ID sudah terdaftar
  Future<bool> checkAndroidID(String androidID) async {
    try {
      final response = await http.post(
        Uri.parse(Endpoint.checkAndroidId),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'androidID': androidID}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(responseData);
        if (responseData['status'] == "already_registered") {
          final String token = responseData['token'];
          final String nrp = responseData['nrp'];
          final String role = responseData['role'];

          // Simpan ke penyimpanan lokal
          await DBService.set("token", token);
          await DBService.set("nrp", nrp);
          await DBService.set("role", role);

          return true;
        }
      }
      return false;
    } catch (err) {
      throw Exception("Gagal memeriksa AndroidID: $err");
    }
  }

  /// Login menggunakan NRP dan password
  Future<void> loginWithNRP({
    required String nrp,
    required String password,
    required String androidId,
    required bool loginAs,
  }) async {
    try {
      final data = {'nrp': nrp, 'password': password, 'androidId': androidId};

      final response = await http.post(
        Uri.parse(Endpoint.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Login berhasil: ${response.body}");
        }
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String token = responseData['token'];
        final String role = responseData['role'];

        await DBService.set("token", token);
        await DBService.set("role", role);
        await DBService.set(
          "expired_at",
          DateTime.now().add(const Duration(hours: 6)).toIso8601String(),
        );
      } else {
        throw Exception("Login gagal. NRP atau password salah.");
      }
    } catch (err) {
      throw Exception("Terjadi kesalahan saat login: $err");
    }
  }

  /// Logout dan hapus token
  Future<void> logout() async {
    await DBService.clear("token");
    await DBService.clear("nrp");
    await DBService.clear("role");
    await DBService.clear("expired_at");
  }

  /// Cek apakah token masih valid
  bool hasValidToken() {
    final token = DBService.get("token");
    final expiredAtString = DBService.get("expired_at");
    if (token == null || expiredAtString == null) return false;

    final expiredAt = DateTime.tryParse(expiredAtString);
    if (expiredAt == null) return false;

    return DateTime.now().isBefore(expiredAt);
  }
}
