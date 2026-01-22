import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test;
import 'package:stylesync/core/crypto/encryption_service.dart';
import 'package:stylesync/core/crypto/key_derivation_service.dart';
import 'package:stylesync/core/crypto/kdf_metadata.dart';

void main() {
  final encryptionService = AESGCMEncryptionService();
  final kdfService = KeyDerivationServiceImpl();

  group('Crypto Property Tests', () {
    // Property 3: Cloud Backup Encryption Round-Trip
    Glados2(any.list(any.int), any.listWithLength(32, any.int)).test(
        'Encryption round-trip preserves data', (data, keyList) async {
      final key = Uint8List.fromList(keyList.map((i) => i & 0xFF).toList());
      final input = Uint8List.fromList(data.map((i) => i & 0xFF).toList());

      final encrypted = await encryptionService.encrypt(input, key);
      final decrypted = await encryptionService.decrypt(encrypted, key);

      expect(decrypted, equals(input));
    });

    // Property 23: Argon2id Key Derivation Consistency
    // Use non-empty string generator since empty passphrases are rejected
    Glados2(any.nonEmptyLowercaseLetters, any.int).test('KDF is consistent for same inputs', (password, seed) async {
      final salt = Uint8List.fromList(List.generate(16, (i) => (i + seed) % 256));
      final metadata = KdfMetadata(
        algorithm: KdfAlgorithm.argon2id,
        salt: salt,
        iterations: 2,
        memory: 1024,
        parallelism: 1,
      );
      
      final key1 = await kdfService.deriveKey(password, metadata);
      final key2 = await kdfService.deriveKey(password, metadata);
      
      expect(key1, equals(key2));
      expect(key1.length, 32);
    });

    // Use non-empty string generator since empty passphrases are rejected
    Glados2(any.nonEmptyLowercaseLetters, any.int).test('PBKDF2 KDF is consistent for same inputs', (password, seed) async {
      final salt = Uint8List.fromList(List.generate(16, (i) => (i + seed) % 256));
      final metadata = KdfMetadata(
        algorithm: KdfAlgorithm.pbkdf2,
        salt: salt,
        iterations: 1000,
      );
      
      final key1 = await kdfService.deriveKey(password, metadata);
      final key2 = await kdfService.deriveKey(password, metadata);
      
      expect(key1, equals(key2));
      expect(key1.length, 32);
    });

    test('Encryption round-trip rejects empty passphrase', () async {
      final salt = Uint8List(16);
      final metadata = KdfMetadata(
        algorithm: KdfAlgorithm.argon2id,
        salt: salt,
        iterations: 2,
        memory: 1024,
        parallelism: 1,
      );
      
      // Empty passphrases are intentionally rejected by the implementation
      expect(
        () => kdfService.deriveKey('', metadata),
        throwsA(isA<ArgumentError>()),
      );
    });

    Glados3(any.list(any.int), any.listWithLength(32, any.int), any.listWithLength(32, any.int))
        .test('Decryption with wrong key fails', (data, keyList1, keyList2) async {
      final key1 = Uint8List.fromList(keyList1.map((i) => i & 0xFF).toList());
      final key2 = Uint8List.fromList(keyList2.map((i) => i & 0xFF).toList());
      
      // Only proceed if keys are actually different
      if (key1.toString() == key2.toString()) return;

      final input = Uint8List.fromList(data.map((i) => i & 0xFF).toList());
      final encrypted = await encryptionService.encrypt(input, key1);

      // AES-GCM decryption with the wrong key should throw a MacValidationException
      // from the cryptography package.
      expect(
        () => encryptionService.decrypt(encrypted, key2),
        throwsA(anything),
      );
    });
  });
}
