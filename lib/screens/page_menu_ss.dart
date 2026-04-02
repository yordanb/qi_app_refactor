import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../providers/ss_provider.dart';
import '../models/ss_filter_params.dart';
import '../screens/page_detil_ss.dart';
import '../auth/login_page.dart';
import '../component/error_handler.dart';

const Map<String, List<String>> _menu2Items = {
  "staff": ["plt2", "pch", "sse", "big wheel", "tere", "lce", "psc"],
  "mech": ["pch", "mobile", "big wheel", "lighting", "pumping", "zero", "<5"],
};

class PageMenuSS extends ConsumerWidget {
  const PageMenuSS({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final filter = ref.watch(ssFilterProvider);
    final ssData = ref.watch(ssDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Sugestion System'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: 'Data copied'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data telah disalin')),
              );
            },
            icon: const Icon(Icons.content_copy),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDropdowns(ref),
          Expanded(
            child: ssData.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AsyncErrorWidget(
                fallbackMessage: e.toString().contains('No internet')
                    ? 'Tidak ada koneksi internet'
                    : 'Gagal memuat data: $e',
                onRetry: () => ref.refresh(ssDataProvider),
              ),
              data: (list) => list.isEmpty
                  ? const Center(child: Text('Tidak ada data'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return ListTile(
                          leading: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PageDetilSS(
                                    nrp: item['nrp'],
                                    nama: item['nama'],
                                  ),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: _getAvatarColor(item['JmlSS']),
                              child: Text(
                                item['JmlSS'].toString(),
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          title: Text('${item['no']}. ${item['nama']}'),
                          subtitle: Text('(${item['nrp']})\n${item['crew']}'),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ⏬ Dropdown builder
  Widget _buildDropdowns(WidgetRef ref) {
    final filter = ref.watch(ssFilterProvider);
    final kategoriList = _menu2Items.keys.toList();
    final subKategoriList = _menu2Items[filter.kategori] ?? [];

    final subOptions = ['pch', 'grader', 'mobile', 'pumping', 'lighting'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          DropdownButton<String>(
            value: filter.kategori,
            items: kategoriList
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
            onChanged: (newKategori) {
              if (newKategori != null) {
                final defaultSub = _menu2Items[newKategori]?.first ?? 'plt2';
                ref.read(ssFilterProvider.notifier).state = filter.copyWith(
                  kategori: newKategori,
                  subKategori: defaultSub,
                  opsiTambahan: null,
                );
              }
            },
          ),
          DropdownButton<String>(
            value: filter.subKategori,
            items: subKategoriList
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
            onChanged: (newSub) {
              if (newSub != null) {
                final opsiTambahan = (newSub == 'zero' || newSub == '<5')
                    ? 'pch'
                    : null;
                ref.read(ssFilterProvider.notifier).state = filter.copyWith(
                  subKategori: newSub,
                  opsiTambahan: opsiTambahan,
                );
              }
            },
          ),
          if (filter.subKategori == 'zero' || filter.subKategori == '<5')
            DropdownButton<String>(
              value: filter.opsiTambahan,
              items: subOptions
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
              onChanged: (newOpsi) {
                if (newOpsi != null) {
                  ref.read(ssFilterProvider.notifier).state = filter.copyWith(
                    opsiTambahan: newOpsi,
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  // ⏬ Color based on jumlah SS
  Color _getAvatarColor(int jmlSS) {
    if (jmlSS < 1) return Colors.redAccent;
    if (jmlSS < 5) return Colors.yellow;
    if (jmlSS < 6) return Colors.lightGreen;
    return Colors.lightBlue;
  }
}

// Kategori dan subkategori
const Map<String, List<String>> _menu2Items = {
  "staff": ["plt2", "pch", "sse", "big wheel", "tere", "lce", "psc"],
  "mech": ["pch", "mobile", "big wheel", "lighting", "pumping", "zero", "<5"],
};
