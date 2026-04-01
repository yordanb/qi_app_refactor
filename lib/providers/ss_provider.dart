import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ss_filter_params.dart';
import '../services/ss_service.dart';
import '../core/storage/secure_storage_service.dart';

/// Simple state management untuk SS filter
/// Menggunakan StateNotifier untuk avoid Riverpod compatibility issues
class SSFilterNotifier extends StateNotifier<SSFilterParams> {
  SSFilterNotifier() : super(const SSFilterParams(
    kategori: 'staff',
    subKategori: 'plt2',
    opsiTambahan: null,
  ));

  void updateKategori(String kategori) {
    final defaultSub = _menu2Items[kategori]?.first ?? 'plt2';
    state = state.copyWith(
      kategori: kategori,
      subKategori: defaultSub,
      opsiTambahan: null,
    );
  }

  void updateSubKategori(String subKategori) {
    final opsiTambahan = (subKategori == 'zero' || subKategori == '<5')
        ? 'pch'  // default
        : null;
    state = state.copyWith(
      subKategori: subKategori,
      opsiTambahan: opsiTambahan,
    );
  }

  void updateOpsiTambahan(String opsi) {
    state = state.copyWith(opsiTambahan: opsi);
  }
}

final ssFilterProvider = StateNotifierProvider<SSFilterNotifier, SSFilterParams>(
  (ref) => SSFilterNotifier(),
);

final ssDataProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final filter = ref.watch(ssFilterProvider);
  final data = await SSService.fetchSSData(filter);
  return data;
});

const Map<String, List<String>> _menu2Items = {
  "staff": ["plt2", "pch", "sse", "big wheel", "tere", "lce", "psc"],
  "mech": ["pch", "mobile", "big wheel", "lighting", "pumping", "zero", "<5"],
};
