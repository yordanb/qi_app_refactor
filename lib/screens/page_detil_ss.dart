import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ss_detil_provider.dart';
import '../core/storage/secure_storage_service.dart';
import '../component/error_handler.dart';

class PageDetilSS extends ConsumerWidget {
  final String nrp;
  final String? nama; // Optional: passed from previous page

  const PageDetilSS({super.key, required this.nrp, this.nama});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailData = ref.watch(ssDetailProvider(nrp));
    final updateInfo = ref.watch(ssUpdateProvider(nrp));

    // Ambil nama dari parameter, atau dari storage, atau default
    final namaAsync = FutureProvider<String?>((ref) async {
      if (nama != null) return nama;
      // Fallback: ambil dari SecureStorage (NRP通常是 nama alternate)
      final storage = SecureStorageService();
      return storage.getNRP(); // atau bisa buat getNama() later
    });

    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, _) {
            final namaValue = ref.watch(namaAsync);
            return namaValue.when(
              data: (val) => Text(val ?? 'Unknown'),
              loading: () => const Text('Loading...'),
              error: (_, __) => const Text('Error'),
            );
          },
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: updateInfo.when(
            data: (val) => Text(val),
            loading: () => const Text('Loading...'),
            error: (_, __) => const Text('Error'),
          ),
        ),
      ),
      body: SafeArea(
        child: detailData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AsyncErrorWidget(
            fallbackMessage: e.toString().contains('No internet')
                ? 'Tidak ada koneksi internet'
                : 'Gagal memuat detail: ${e.toString()}',
            onRetry: () => ref.refresh(ssDetailProvider(nrp)),
          ),
          data: (list) => list.isEmpty
              ? const Center(child: Text('Tidak ada data detail'))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: _getAvatarColor(item['no']),
                        foregroundColor: Colors.black,
                        child: Text(
                          item['no'].toString(),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      title: Text(item['judul'] ?? '-'),
                      subtitle: Text(
                        'Status : ${item['status'] ?? '-'}\nCreated : ${item['create'] ?? '-'}',
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Color _getAvatarColor(int jmlSS) {
    if (jmlSS < 1) return Colors.redAccent;
    if (jmlSS < 5) return Colors.yellow;
    if (jmlSS < 6) return Colors.lightGreen;
    return Colors.lightBlue;
  }
}
