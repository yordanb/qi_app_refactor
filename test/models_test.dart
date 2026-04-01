import 'package:flutter_test/flutter_test.dart';
import 'package:qi_app_refact/models/kpi_model.dart';

void main() {
  group('KPIModel', () {
    test('should parse JSON correctly', () {
      final json = {
        'update': '2025-03-27',
        'response': [
          {'no': 1, 'label': 'KPI 1', 'value': 85.5},
          {'no': 2, 'label': 'KPI 2', 'value': 92.0},
        ],
      };

      final kpi = KPIModel.fromJson(json);

      expect(kpi.update, '2025-03-27');
      expect(kpi.items.length, 2);
      expect(kpi.items[0].label, 'KPI 1');
      expect(kpi.items[0].value, 85.5);
      expect(kpi.items[1].value, 92.0);
    });

    test('should handle missing fields gracefully', () {
      final json = {
        'response': [
          {'no': 1, 'label': 'Only Label'}, // missing value
        ],
      };

      final kpi = KPIModel.fromJson(json);

      expect(kpi.items[0].value, 0.0);
    });
  });

  group('SSFilterParams', () {
    test('should create with required fields', () {
      final filter = SSFilterParams(
        kategori: 'staff',
        subKategori: 'plt2',
      );

      expect(filter.kategori, 'staff');
      expect(filter.subKategori, 'plt2');
      expect(filter.opsiTambahan, null);
    });

    test('should copyWith correctly', () {
      const original = SSFilterParams(
        kategori: 'staff',
        subKategori: 'plt2',
      );

      final modified = original.copyWith(subKategori: 'pch');

      expect(modified.kategori, 'staff');
      expect(modified.subKategori, 'pch');
      expect(original.subKategori, 'plt2'); // original unchanged
    });
  });
}
