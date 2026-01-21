import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylesync/core/crypto/kdf_metadata.dart';

void main() {
  group('KdfMetadata.fromJson Validation', () {
    test('successfully parses valid JSON', () {
      final json = {
        'algorithm': 'argon2id',
        'salt': base64Encode(Uint8List.fromList([1, 2, 3])),
        'iterations': 1000,
        'memory': 1024,
        'parallelism': 1,
      };
      
      final metadata = KdfMetadata.fromJson(json);
      
      expect(metadata.algorithm, KdfAlgorithm.argon2id);
      expect(metadata.salt, equals([1, 2, 3]));
      expect(metadata.iterations, 1000);
      expect(metadata.memory, 1024);
      expect(metadata.parallelism, 1);
    });

    test('successfully parses valid JSON with default memory/parallelism', () {
      final json = {
        'algorithm': 'pbkdf2',
        'salt': base64Encode(Uint8List.fromList([1, 2, 3])),
        'iterations': 1000,
      };
      
      final metadata = KdfMetadata.fromJson(json);
      
      expect(metadata.algorithm, KdfAlgorithm.pbkdf2);
      expect(metadata.memory, 0);
      expect(metadata.parallelism, 0);
    });

    test('throws FormatException when required keys are missing', () {
      final json = {
        'algorithm': 'argon2id',
        'salt': 'c2FsdA==',
        // 'iterations' missing
      };
      
      expect(() => KdfMetadata.fromJson(json), throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('Missing required key: iterations'))));
    });

    test('throws FormatException for invalid algorithm', () {
      final json = {
        'algorithm': 'invalid_algo',
        'salt': 'c2FsdA==',
        'iterations': 1000,
      };
      
      expect(() => KdfMetadata.fromJson(json), throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('Invalid or unknown KDF algorithm'))));
    });

    test('throws FormatException for invalid base64 salt', () {
      final json = {
        'algorithm': 'argon2id',
        'salt': 'invalid base64!',
        'iterations': 1000,
      };
      
      expect(() => KdfMetadata.fromJson(json), throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('Invalid base64 encoding for salt'))));
    });

    test('throws FormatException when integer fields are not integers', () {
      final json = {
        'algorithm': 'argon2id',
        'salt': 'c2FsdA==',
        'iterations': '1000', // String instead of int
      };
      
      expect(() => KdfMetadata.fromJson(json), throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('iterations must be an integer'))));
    });

    test('throws ArgumentError for negative integer values', () {
      final json = {
        'algorithm': 'argon2id',
        'salt': 'c2FsdA==',
        'iterations': -1,
      };
      
      expect(() => KdfMetadata.fromJson(json), throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('iterations must be non-negative'))));
    });
  });
}
