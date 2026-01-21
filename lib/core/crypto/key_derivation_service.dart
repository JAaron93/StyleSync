import 'dart:math';
import 'dart:typed_data';
import 'package:argon2/argon2.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:platform/platform.dart';
import 'kdf_metadata.dart';

abstract class KeyDerivationService {
  /// Derives a 32-byte key from a passphrase and metadata.
  Future<Uint8List> deriveKey(String passphrase, KdfMetadata metadata);

  /// Generates initial metadata for a new key derivation.
  Future<KdfMetadata> generateMetadata();
}

class KeyDerivationServiceImpl implements KeyDerivationService {
  final Platform _platform;

  KeyDerivationServiceImpl({Platform? platform}) : _platform = platform ?? const LocalPlatform();

  @override
  Future<Uint8List> deriveKey(String passphrase, KdfMetadata metadata) async {
    switch (metadata.algorithm) {
      case KdfAlgorithm.argon2id:
        return _deriveWithArgon2id(passphrase, metadata);
      case KdfAlgorithm.pbkdf2:
        return _deriveWithPbkdf2(passphrase, metadata);
    }
  }

  @override
  Future<KdfMetadata> generateMetadata() async {
    final salt = _generateRandomSalt(16);
    if (!kIsWeb && (_platform.isAndroid || _platform.isIOS || _platform.isMacOS)) {
      return KdfMetadata(
        algorithm: KdfAlgorithm.argon2id,
        salt: salt,
        iterations: 3,
        memory: 64 * 1024, // 64MB in KB
        parallelism: 4,
      );
    } else {
      return KdfMetadata(
        algorithm: KdfAlgorithm.pbkdf2,
        salt: salt,
        iterations: 600000,
      );
    }
  }

  Future<Uint8List> _deriveWithArgon2id(String passphrase, KdfMetadata metadata) async {
    return compute(
      _deriveArgon2Bytes,
      _Argon2Arguments(
        passphrase: passphrase,
        salt: metadata.salt,
        iterations: metadata.iterations,
        memory: metadata.memory,
        parallelism: metadata.parallelism,
      ),
    );
  }

  Future<Uint8List> _deriveWithPbkdf2(String passphrase, KdfMetadata metadata) async {
    final pbkdf2 = crypto.Pbkdf2(
      macAlgorithm: crypto.Hmac.sha512(),
      iterations: metadata.iterations,
      bits: 256,
    );
    final secretKey = await pbkdf2.deriveKeyFromPassword(
      password: passphrase,
      nonce: metadata.salt,
    );
    final bytes = await secretKey.extractBytes();
    return Uint8List.fromList(bytes);
  }

  Uint8List _generateRandomSalt(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
  }
}

class _Argon2Arguments {
  final String passphrase;
  final Uint8List salt;
  final int iterations;
  final int memory;
  final int parallelism;

  _Argon2Arguments({
    required this.passphrase,
    required this.salt,
    required this.iterations,
    required this.memory,
    required this.parallelism,
  });
}

Uint8List _deriveArgon2Bytes(_Argon2Arguments args) {
  final parameters = Argon2Parameters(
    Argon2Parameters.ARGON2_id,
    args.salt,
    iterations: args.iterations,
    memory: args.memory,
    lanes: args.parallelism,
  );
  final generator = Argon2BytesGenerator();
  generator.init(parameters);
  final result = Uint8List(32);
  generator.generateBytesFromString(args.passphrase, result, 0, 32);
  return result;
}
