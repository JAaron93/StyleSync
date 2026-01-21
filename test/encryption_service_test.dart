import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylesync/core/crypto/encryption_service.dart';

void main() {
  late EncryptionService encryptionService;
  late Uint8List dummyKey;

  setUp(() {
    encryptionService = AESGCMEncryptionService();
    dummyKey = Uint8List.fromList(List.generate(32, (i) => i));
  });

  group('EncryptionService Unit Tests', () {
    test('Round-trip encryption/decryption success', () async {
      final plainText = Uint8List.fromList('Hello Secure World!'.codeUnits);
      
      final cipherText = await encryptionService.encrypt(plainText, dummyKey);
      final decrypted = await encryptionService.decrypt(cipherText, dummyKey);
      
      expect(decrypted, equals(plainText));
      expect(cipherText.length, 12 + plainText.length + 16); // Nonce (12) + Length + MAC (16)
    });

    test('Encryption produces different ciphertexts for same plainText (nonce uniqueness)', () async {
      final plainText = Uint8List.fromList('Same data'.codeUnits);
      
      final cipher1 = await encryptionService.encrypt(plainText, dummyKey);
      final cipher2 = await encryptionService.encrypt(plainText, dummyKey);
      
      expect(cipher1, isNot(equals(cipher2)));
    });

    test('Decryption fails with wrong key', () async {
      final plainText = Uint8List.fromList('Sensitive data'.codeUnits);
      final cipherText = await encryptionService.encrypt(plainText, dummyKey);
      
      final wrongKey = Uint8List.fromList(List.generate(32, (i) => i + 1));
      
      expect(
        () => encryptionService.decrypt(cipherText, wrongKey),
        throwsException, // cryptography package throws an exception on auth failure
      );
    });

    test('Decryption fails if ciphertext is tampered', () async {
      final plainText = Uint8List.fromList('Sensitive data'.codeUnits);
      final cipherText = await encryptionService.encrypt(plainText, dummyKey);
      
      // Tamper with the ciphertext part
      cipherText[15] = cipherText[15] ^ 0xFF;
      
      expect(
        () => encryptionService.decrypt(cipherText, dummyKey),
        throwsException,
      );
    });
  });
}
