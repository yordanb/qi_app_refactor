import 'package:flutter_test/flutter_test.dart';
import 'package:qi_app_refact/core/storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Mock class to avoid real secure storage in tests
class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('SecureStorageService', () {
    test('should store and retrieve string', () async {
      // This is a placeholder test - in production use mockito
      // For now, we'll just test the API contract
      final storage = SecureStorageService();

      // These tests require real device/emulator setup
      // Consider using flutter_secure_storage_test for unit tests
    });
  });

  group('DioClient', () {
    test('should be singleton', () {
      final client1 = DioClient();
      final client2 = DioClient();

      expect(identical(client1, client2), true);
    });

    test('should have correct base URL in development', () {
      // Note: This depends on compile-time flag
      // For testing, we can check the _baseUrl directly with reflection
      // or expose a getter for testing
    });
  });
}
