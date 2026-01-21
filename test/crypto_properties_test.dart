import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:stylesync/core/crypto/encryption_service.dart';
import 'package:stylesync/core/crypto/key_derivation_service.dart';
import 'package:stylesync/core/crypto/kdf_metadata.dart';

void main() {
  final encryptionService = AESGCMEncryptionService();
  final kdfService = KeyDerivationServiceImpl();

  group('Crypto Property Tests', () {
    // Property 3: Cloud Backup Encryption Round-Trip
    Glados(any.list(any.int8)).test('Encryption round-trip preserves data', (data) async {
      final key = Uint8List.fromList(List.generate(32, (i) => i));
      final input = Uint8List.fromList(data);
      
      final encrypted = await encryptionService.encrypt(input, key);
      final decrypted = await encryptionService.decrypt(encrypted, key);
      
      expect(decrypted, equals(input));
    });

    // Property 23: Argon2id Key Derivation Consistency
    Glados2(any.lowercaseLetters, any.int).test('KDF is consistent for same inputs', (password, seed) async {
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

    Glados2(any.lowercaseLetters, any.int).test('PBKDF2 KDF is consistent for same inputs', (password, seed) async {
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
  });
}
