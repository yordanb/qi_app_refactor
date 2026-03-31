class KPIModel {
  final String update;
  final List<KPIItem> items;

  KPIModel({required this.update, required this.items});

  factory KPIModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> responseList = json['response'] ?? [];
    final List<KPIItem> items = responseList
        .map((item) => KPIItem.fromJson(item))
        .toList();

    return KPIModel(update: json['update'] ?? '', items: items);
  }
}

class KPIItem {
  final int no;
  final String label;
  final double value;

  KPIItem({required this.no, required this.label, required this.value});

  factory KPIItem.fromJson(Map<String, dynamic> json) {
    return KPIItem(
      no: json['no'] ?? 0,
      label: json['label'] ?? '',
      value: double.tryParse(json['value'].toString()) ?? 0.0,
    );
  }
}
