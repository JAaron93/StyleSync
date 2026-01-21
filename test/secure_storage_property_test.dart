import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:platform/platform.dart';
import 'package:stylesync/core/storage/secure_storage_service.dart';
import 'package:stylesync/core/storage/secure_storage_service_impl.dart';

void main() {
  group('SecureStorageServiceImpl Property Tests', () {
    Glados(any.int).test('Backend selection based on platform', (char) {
      // Test Android
      final androidPlatform = FakePlatform(operatingSystem: 'android');
      final androidService = SecureStorageServiceImpl(platform: androidPlatform);
      expect(androidService.backend, SecureStorageBackend.hardwareBacked);

      // Test iOS
      final iosPlatform = FakePlatform(operatingSystem: 'ios');
      final iosService = SecureStorageServiceImpl(platform: iosPlatform);
      expect(iosService.backend, SecureStorageBackend.hardwareBacked);

      // Test other (e.g., macOS/Web - currently defaults to software in our impl)
      final otherPlatform = FakePlatform(operatingSystem: 'macos');
      final otherService = SecureStorageServiceImpl(platform: otherPlatform);
      expect(otherService.backend, SecureStorageBackend.software);
    });
  });
}
