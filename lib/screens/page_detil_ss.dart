import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ss_detil_provider.dart';
import '../auth/db_service.dart';

class PageDetilSS extends ConsumerWidget {
  final String nrp;

  const PageDetilSS({super.key, required this.nrp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailData = ref.watch(ssDetailProvider(nrp));
    final updateInfo = ref.watch(ssUpdateProvider(nrp));
    final namaAsync = FutureProvider<String?>((ref) => DBService.get("nama"));

    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, _) {
            final nama = ref.watch(namaAsync);
            return nama.when(
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
          error: (e, _) => const Center(child: Text('Error')),
          data: (list) => ListView.builder(
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
