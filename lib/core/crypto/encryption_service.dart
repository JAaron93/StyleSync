import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

abstract class EncryptionService {
  /// Encrypts [data] using [key] (32-byte). Returns [nonce + ciphertext + mac].
  Future<Uint8List> encrypt(Uint8List data, Uint8List key);

  /// Decrypts [encryptedData] using [key] (32-byte). Expects [nonce + ciphertext + mac].
  Future<Uint8List> decrypt(Uint8List encryptedData, Uint8List key);
}

class AESGCMEncryptionService implements EncryptionService {
  final AesGcm _algorithm = AesGcm.with256bits();

  @override
  Future<Uint8List> encrypt(Uint8List data, Uint8List key) async {
    if (key.length != 32) {
      throw ArgumentError('Key must be exactly 32 bytes for AES-256');
    }
    final secretKey = SecretKey(key);
    // AesGcm generates a random 96-bit nonce by default if not provided.
    final secretBox = await _algorithm.encrypt(
      data,
      secretKey: secretKey,
    );
    
    // Combine nonce, ciphertext, and mac into a single blob.
    // secretBox.concatenation() returns nonce + ciphertext + mac.
    return Uint8List.fromList(secretBox.concatenation());
  }

  @override
  Future<Uint8List> decrypt(Uint8List encryptedData, Uint8List key) async {
    if (key.length != 32) {
      throw ArgumentError('Key must be exactly 32 bytes for AES-256');
    }
    if (encryptedData.length < 28) {
      throw ArgumentError(
        'Encrypted data is too short (must be at least 28 bytes for nonce and MAC)',
      );
    }
    final secretKey = SecretKey(key);
    
    // AesGcm expects a 12-byte (96-bit) nonce and a 16-byte mac.
    final secretBox = SecretBox.fromConcatenation(
      encryptedData,
      nonceLength: 12,
      macLength: 16,
    );
    
    final clearText = await _algorithm.decrypt(
       secretBox,
       secretKey: secretKey,
    );
    
    return Uint8List.fromList(clearText);
  }
}
