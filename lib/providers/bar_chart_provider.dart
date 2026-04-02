import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../config/config.dart';

final barChartProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async {
    final dioClient = DioClient();
    final storage = SecureStorageService();
    final token = await storage.getToken();

    final List<String> endpoints = [
      "/ss-all-plt2",
      "/jarvis-all-plt2",
      "/ipeak-all-plt2",
      "/ss-zero-mech-plt2",
      "/ss-zero-staff-plt2",
      "/ss-approval",
      "/ss-5-mech-plt2",
      "/ss-5-staff-plt2",
    ];

    final futures = endpoints.map((endpoint) async {
      try {
        final response = await dioClient.dio.get(
          AppConfig.apiUrl + endpoint,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        if (response.statusCode == 200) {
          return {
            "kpi": response.data['kpi'],
            "response": List<Map<String, dynamic>>.from(
              response.data['response'],
            ),
          };
        }
        return null; // failed but continue
      } catch (e) {
        if (kDebugMode) {
          print('Failed to load $endpoint: $e');
        }
        return null; // failed but continue (partial success)
      }
    });

    final results = await Future.wait(futures);
    final successful = results.where((r) => r != null).toList();

    if (successful.isEmpty) {
      throw Exception("Failed to load any bar chart data");
    }

    return successful.cast<Map<String, dynamic>>();
  },
);
