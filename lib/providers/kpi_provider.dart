import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/db_service.dart';
import '../models/kpi_model.dart';
import '../services/kpi_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

final kpiProvider = FutureProvider<KPIModel>((ref) async {
  return await KPIService.fetchKPIData();
});

final barChartProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final token = DBService.get("token");

  final List<String> endpoints = [
    "/api/ss-all-plt2",
    "/api/jarvis-all-plt2",
    "/api/ipeak-all-plt2",
    "/api/ss-zero-mech-plt2",
    "/api/ss-zero-staff-plt2",
    "/api/ss-approval",
    "/api/ss-5-mech-plt2",
    "/api/ss-5-staff-plt2",
  ];

  final responses = await Future.wait(
    endpoints.map(
      (endpoint) => http.get(
        Uri.parse(Config.apiUrl + endpoint),
        headers: {'Authorization': 'Bearer $token'},
      ),
    ),
  );

  if (responses.every((r) => r.statusCode == 200)) {
    return responses.map((r) {
      final body = json.decode(r.body);
      return {
        "kpi": body['kpi'],
        "response": List<Map<String, dynamic>>.from(body['response']),
      };
    }).toList();
  } else {
    throw Exception("Failed to load some bar chart data");
  }
});
