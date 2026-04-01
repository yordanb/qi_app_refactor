import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';

final connectivityProvider = StreamProvider<bool>((ref) async* {
  final dioClient = DioClient();
  // Initial check
  yield await dioClient.hasInternetConnection();

  // TODO: Add real-time connectivity stream using connectivity_plus
  // For now, we'll just check on app start
});