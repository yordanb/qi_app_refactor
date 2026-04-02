import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/ss_filter_params.dart';
import '../services/ss_service.dart';

/// Simple state provider untuk SS filter
/// Menggunakan StateProvider with copyWith pattern
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
