import "package:flutter/foundation.dart";
import "package:android_id/android_id.dart";

import "../core/network/dio_client.dart";
import "../core/storage/secure_storage_service.dart";
import "../core/errors/exceptions.dart";
import "db_service.dart"; // TODO: Remove after migration complete

class AuthService {
  final DioClient _dioClient = DioClient();

  /// Ambil Android ID
  Future<String?> getAndroidId() async {
    const androidIdPlugin = AndroidId();
    return androidIdPlugin.getId();
  }

  /// Mengecek apakah Android ID sudah terdaftar
  Future<bool> checkAndroidID(String androidID) async {
    try {
      final response = await _dioClient.dio.post(
        "/auth/id-cek",
        data: {"androidID": androidID},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (kDebugMode) {
          print(responseData);
        }
        if (responseData["status"] == "already_registered") {
          final String token = responseData["token"];
          final String nrp = responseData["nrp"];
          final String role = responseData["role"];
          final String? refreshToken = responseData["refresh_token"];

          // Simpan ke secure storage
          await SecureStorageService.setToken(token);
          if (refreshToken != null) {
            await SecureStorageService.setRefreshToken(refreshToken);
          }
          await SecureStorageService.setNRP(nrp);
          await SecureStorageService.setRole(role);
          // Jangan simpan expired_at karena backend handle refresh

          return true;
        }
      }
      return false;
    } on UnauthorizedException catch (_) {
      rethrow;
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
      final response = await _dioClient.dio.post(
        "/auth/login",
        data: {"nrp": nrp, "password": password, "androidId": androidId},
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Login berhasil: ${response.data}");
        }
        final responseData = response.data;
        final String token = responseData["token"];
        final String refreshToken = responseData["refresh_token"];
        final String role = responseData["role"];

        await SecureStorageService.setToken(token);
        await SecureStorageService.setRefreshToken(refreshToken);
        await SecureStorageService.setNRP(nrp);
        await SecureStorageService.setRole(role);

        // Legacy: simpan juga ke SharedPreferences untuk一時 migration
        await DBService.set("token", token);
        await DBService.set("nrp", nrp);
        await DBService.set("role", role);
      } else {
        throw ApiException(
          response.data?["message"] ?? "Login gagal. NRP atau password salah.",
          statusCode: response.statusCode,
        );
      }
    } on UnauthorizedException catch (_) {
      rethrow;
    } catch (err) {
      throw Exception("Terjadi kesalahan saat login: $err");
    }
  }

  /// Logout dan hapus token
  Future<void> logout() async {
    await SecureStorageService.clearAuth();
    await DBService.clear("token");
    await DBService.clear("nrp");
    await DBService.clear("role");
    await DBService.clear("expired_at");
  }

  /// Cek apakah token masih valid (backend akan handle via refresh)
  Future<bool> hasValidToken() async {
    final token = await SecureStorageService.getToken();
    final expiredAtString = await SecureStorageService.getExpiredAt();
    if (token == null || expiredAtString == null) return false;

    final expiredAt = DateTime.tryParse(expiredAtString);
    if (expiredAt == null) return false;

    return DateTime.now().isBefore(expiredAt);
  }

  /// Get current role dari secure storage
  Future<String?> getRole() async {
    return SecureStorageService.getRole();
  }
}
