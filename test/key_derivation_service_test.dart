import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';
import 'package:stylesync/core/crypto/key_derivation_service.dart';
import 'package:stylesync/core/crypto/kdf_metadata.dart';

void main() {
  late KeyDerivationService kdfService;

  setUp(() {
    kdfService = KeyDerivationServiceImpl();
  });

  group('KeyDerivationService Unit Tests', () {
    test('generateMetadata produces different salts', () async {
      final meta1 = await kdfService.generateMetadata();
      final meta2 = await kdfService.generateMetadata();
      
      expect(meta1.salt, isNot(equals(meta2.salt)));
    });

    test('deriveKey produces consistent results for Argon2id', () async {
      final salt = Uint8List.fromList(List.generate(16, (i) => i));
      final metadata = KdfMetadata(
        algorithm: KdfAlgorithm.argon2id,
        salt: salt,
        iterations: 2,
        memory: 1024, // 1MB
        parallelism: 1,
      );
      
      final key1 = await kdfService.deriveKey('password123', metadata);
      final key2 = await kdfService.deriveKey('password123', metadata);
      
      expect(key1, equals(key2));
      expect(key1.length, 32);
    });

    test('deriveKey produces consistent results for PBKDF2', () async {
      final salt = Uint8List.fromList(List.generate(16, (i) => i));
      final metadata = KdfMetadata(
        algorithm: KdfAlgorithm.pbkdf2,
        salt: salt,
        iterations: 1000,
      );
      
      final key1 = await kdfService.deriveKey('password123', metadata);
      final key2 = await kdfService.deriveKey('password123', metadata);
      
      expect(key1, equals(key2));
      expect(key1.length, 32);
    });

    test('deriveKey produces different keys for different passwords', () async {
      final meta = await kdfService.generateMetadata();
      final key1 = await kdfService.deriveKey('password1', meta);
      final key2 = await kdfService.deriveKey('password2', meta);
      
      expect(key1, isNot(equals(key2)));
    });

    test('Metadata selection based on platform', () async {
      final androidService = KeyDerivationServiceImpl(
        platform: FakePlatform(operatingSystem: 'android'),
      );
      final iosService = KeyDerivationServiceImpl(
        platform: FakePlatform(operatingSystem: 'ios'),
      );
      final linuxService = KeyDerivationServiceImpl(
        platform: FakePlatform(operatingSystem: 'linux'),
      );

      final androidMeta = await androidService.generateMetadata();
      expect(androidMeta.algorithm, KdfAlgorithm.argon2id);

      final iosMeta = await iosService.generateMetadata();
      expect(iosMeta.algorithm, KdfAlgorithm.argon2id);

      final linuxMeta = await linuxService.generateMetadata();
      expect(
      linuxMeta.algorithm,
      KdfAlgorithm.pbkdf2,
      // Linux doesn't support Argon2id, so generateMetadata() falls back to KdfAlgorithm.pbkdf2.
    );
    });
  });
}
