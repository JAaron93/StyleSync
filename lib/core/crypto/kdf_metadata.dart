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
    return KdfMetadata(
      algorithm: KdfAlgorithm.values.byName(json['algorithm']),
      salt: base64Decode(json['salt']),
      iterations: json['iterations'],
      memory: json['memory'] ?? 0,
      parallelism: json['parallelism'] ?? 0,
    );
  }
}
