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
        reason: 'Linux falls back to PBKDF2 since Argon2id is not supported',
      );
    });

    test('deriveKey rejects empty passphrase', () async {
      final meta = await kdfService.generateMetadata();
      
      expect(
        () => kdfService.deriveKey('', meta),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Passphrase cannot be empty'),
        )),
      );
    });
  });

  group('Algorithm Validation Tests', () {
    test('validateAlgorithm accepts all supported algorithms', () async {
      final service = KeyDerivationServiceImpl();
      
      // Test Argon2id
      final argon2Meta = KdfMetadata(
        algorithm: KdfAlgorithm.argon2id,
        salt: Uint8List(16),
        iterations: 3,
        memory: 1024,
        parallelism: 1,
      );
      
      expect(
        () => service.deriveKey('test-password', argon2Meta),
        returnsNormally,
      );
      
      // Test PBKDF2
      final pbkdf2Meta = KdfMetadata(
        algorithm: KdfAlgorithm.pbkdf2,
        salt: Uint8List(16),
        iterations: 1000,
      );
      
      expect(
        () => service.deriveKey('test-password', pbkdf2Meta),
        returnsNormally,
      );
    });
  });
}
