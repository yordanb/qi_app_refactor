import 'package:flutter/foundation.dart';

import '../core/network/dio_client.dart';
import '../models/ss_filter_params.dart';
import '../core/storage/secure_storage_service.dart';
import '../config/endpoints.dart';

class SSService {
  static final DioClient _dioClient = DioClient();
  static final SecureStorageService _storage = SecureStorageService();

  static Future<List<dynamic>> fetchSSData(SSFilterParams params) async {
    try {
      final url = Endpoint.ss(params);
      final token = await _storage.getToken();

      final response = await _dioClient.dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;
        return jsonData['response'] ?? [];
      } else {
        throw Exception('Gagal memuat data SS: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SSService Error: $e');
      }
      rethrow;
    }
  }
}
