import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../auth/db_service.dart';
import '../config/endpoints.dart';

// Provider untuk ambil nama user dari SharedPreferences
final userNameProvider = FutureProvider<String?>((ref) async {
  return DBService.get("nama");
});

// Provider untuk ambil data detail SS berdasarkan NRP
final ssDetailProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  nrp,
) async {
  final url = "${Endpoint.api}/ss/$nrp";
  final token = DBService.get("token");
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['response'] ?? [];
  } else {
    throw Exception('Gagal memuat data SS');
  }
});

// Provider untuk ambil data update terakhir berdasarkan NRP
final ssUpdateProvider = FutureProvider.family<String, String>((
  ref,
  nrp,
) async {
  final url = "${Endpoint.api}/ss/$nrp";
  final token = DBService.get("token");
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['update'] ?? 'Maaf Anda belum membuat SS';
  } else {
    return 'No Data';
  }
});
