// TODO Implement this library.
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/db_service.dart';
import '../models/ss_filter_params.dart';
import '../config/endpoints.dart';

class SSService {
  static Future<List<dynamic>> fetchSSData(SSFilterParams params) async {
    final url = Endpoint.ss(params);
    final token = DBService.get("token");
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['response'] ?? [];
    } else {
      throw Exception('Gagal memuat data SS');
    }
  }
}
