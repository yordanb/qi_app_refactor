import "package:flutter/foundation.dart";
import "package:android_id/android_id.dart";

import "../core/network/dio_client.dart";
import "../core/storage/secure_storage_service.dart";
import "../core/errors/exceptions.dart";

class AuthService {
  final DioClient _dioClient = DioClient();
  final SecureStorageService _storage = SecureStorageService();

  /// Ambil Android ID
  Future<String?> getAndroidId() async {
    const androidIdPlugin = AndroidId();
    return await androidIdPlugin.getId();
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
          await _storage.setToken(token);
          if (refreshToken != null) {
            await _storage.setRefreshToken(refreshToken);
          }
          await _storage.setNRP(nrp);
          await _storage.setRole(role);

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

        await _storage.setToken(token);
        await _storage.setRefreshToken(refreshToken);
        await _storage.setNRP(nrp);
        await _storage.setRole(role);

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
    await _storage.clearAuth();
  }

  /// Cek apakah user sudah login (ada token)
  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null;
  }

  /// Get current role dari secure storage
  Future<String?> getRole() async {
    return await _storage.getRole();
  }

  /// Get NRP dari secure storage
  Future<String?> getNRP() async {
    return await _storage.getNRP();
  }
}
