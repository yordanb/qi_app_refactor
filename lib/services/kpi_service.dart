import "package:flutter/foundation.dart";

import "../core/network/dio_client.dart";
import "../models/kpi_model.dart";
import "../core/storage/secure_storage_service.dart";
import "../config/endpoints.dart";

class KPIService {
  static final DioClient _dioClient = DioClient();
  static final SecureStorageService _storage = SecureStorageService();

  static Future<KPIModel> fetchKPIData() async {
    try {
      final token = await _storage.getToken();

      final response = await _dioClient.dio.get(
        Endpoint.kpiAll,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return KPIModel.fromJson(response.data);
      } else {
        throw Exception("Gagal memuat data KPI: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("KPIService Error: $e");
      }
      rethrow;
    }
  }
}
