import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kpi_model.dart';
import '../services/kpi_service.dart';

final kpiProvider = FutureProvider.autoDispose<KPIModel>((ref) async {
  return KPIService.fetchKPIData();
});
