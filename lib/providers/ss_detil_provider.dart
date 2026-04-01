import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../config/endpoints.dart';

// Provider untuk ambil nama user dari SecureStorage
final userNameProvider = FutureProvider<String?>((ref) async {
  final storage = SecureStorageService();
  return storage.getNRP(); // atau bisa juga getRole/ custom field
});

// Provider untuk ambil data detail SS berdasarkan NRP
final ssDetailProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  nrp,
) async {
  final dioClient = DioClient();
  final storage = SecureStorageService();
  final token = await storage.getToken();

  final url = "${Endpoint.api}/ss/$nrp";

  try {
    final response = await dioClient.dio.get(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      return response.data['response'] ?? [];
    } else {
      throw Exception('Gagal memuat data SS: ${response.statusCode}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('ssDetailProvider error: $e');
    }
    rethrow;
  }
});

// Provider untuk ambil data update terakhir berdasarkan NRP
final ssUpdateProvider = FutureProvider.family<String, String>((
  ref,
  nrp,
) async {
  final dioClient = DioClient();
  final storage = SecureStorageService();
  final token = await storage.getToken();

  final url = "${Endpoint.api}/ss/$nrp";

  try {
    final response = await dioClient.dio.get(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      return response.data['update'] ?? 'Maaf Anda belum membuat SS';
    } else {
      return 'No Data';
    }
  } catch (e) {
    if (kDebugMode) {
      print('ssUpdateProvider error: $e');
    }
    return 'No Data';
  }
});
