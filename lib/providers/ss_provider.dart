import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ss_filter_params.dart';
import '../services/ss_service.dart';
import '../core/storage/secure_storage_service.dart';

const Map<String, List<String>> _menu2Items = {
  "staff": ["plt2", "pch", "sse", "big wheel", "tere", "lce", "psc"],
  "mech": ["pch", "mobile", "big wheel", "lighting", "pumping", "zero", "<5"],
};

/// Simple state management menggunakan StateProvider dengan copyWith
final ssFilterProvider = StateProvider<SSFilterParams>((ref) {
  return const SSFilterParams(
    kategori: 'staff',
    subKategori: 'plt2',
    opsiTambahan: null,
  );
});

final ssDataProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final filter = ref.watch(ssFilterProvider);
  final data = await SSService.fetchSSData(filter);
  return data;
});
