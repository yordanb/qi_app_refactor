import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qi_app_refact/config/endpoints.dart';
import '../models/kpi_model.dart';
import '../auth/db_service.dart';

class KPIService {
  static Future<KPIModel> fetchKPIData() async {
    final token = await DBService.get("token");
    final response = await http.get(
      Uri.parse(Endpoint.kpiAll),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return KPIModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat data KPI');
    }
  }
}
