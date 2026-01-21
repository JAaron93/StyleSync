import 'dart:convert';
import 'dart:typed_data';

enum KdfAlgorithm {
  argon2id,
  pbkdf2,
}

class KdfMetadata {
  final KdfAlgorithm algorithm;
  final Uint8List salt;
  final int iterations;
  final int memory;
  final int parallelism;

  KdfMetadata({
    required this.algorithm,
    required this.salt,
    required this.iterations,
    this.memory = 0,
    this.parallelism = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'algorithm': algorithm.name,
      'salt': base64Encode(salt),
      'iterations': iterations,
      'memory': memory,
      'parallelism': parallelism,
    };
  }

  factory KdfMetadata.fromJson(Map<String, dynamic> json) {
    // Check required keys
    for (final key in ['algorithm', 'salt', 'iterations']) {
      if (!json.containsKey(key)) {
        throw FormatException('Missing required key: $key');
      }
    }

    // Validate algorithm
    final KdfAlgorithm algorithm;
    try {
      algorithm = KdfAlgorithm.values.byName(json['algorithm'] as String);
    } catch (e) {
      throw FormatException('Invalid or unknown KDF algorithm: ${json['algorithm']}');
    }

    // Validate salt
    final Uint8List salt;
    try {
      salt = base64Decode(json['salt'] as String);
    } catch (e) {
      throw FormatException('Invalid base64 encoding for salt: ${e.toString()}');
    }

    // Validate integers
    int validateInt(dynamic value, String name) {
      if (value is! int) {
        throw FormatException('$name must be an integer');
      }
      if (value < 0) {
        throw FormatException('$name must be non-negative');
      }
      return value;
    }

    return KdfMetadata(
      algorithm: algorithm,
      salt: salt,
      iterations: validateInt(json['iterations'], 'iterations'),
      memory: validateInt(json['memory'] ?? 0, 'memory'),
      parallelism: validateInt(json['parallelism'] ?? 0, 'parallelism'),
    );
  }
}
