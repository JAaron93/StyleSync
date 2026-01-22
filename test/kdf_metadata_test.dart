import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylesync/core/crypto/kdf_metadata.dart';

void main() {
  group('KdfMetadata.fromJson Validation', () {
    // Standardized salt for all tests
    final standardSalt = base64Encode(Uint8List.fromList([1, 2, 3, 4]));

    test('successfully parses valid JSON', () {
      final json = {
        'algorithm': 'argon2id',
        'salt': standardSalt,
        'iterations': 1000,
        'memory': 1024,
        'parallelism': 1,
      };

      final metadata = KdfMetadata.fromJson(json);

      expect(metadata.algorithm, KdfAlgorithm.argon2id);
      expect(metadata.salt, equals([1, 2, 3, 4]));
      expect(metadata.iterations, 1000);
      expect(metadata.memory, 1024);
      expect(metadata.parallelism, 1);
    });

    test('successfully parses valid JSON with default memory/parallelism', () {
      final json = {
        'algorithm': 'pbkdf2',
        'salt': standardSalt,
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
        'salt': standardSalt,
        // 'iterations' missing
      };

      final matcher = isA<FormatException>().having(
        (e) => e.message,
        'message',
        contains('Missing required key: iterations'),
      );

      expect(() => KdfMetadata.fromJson(json), throwsA(matcher));
    });

    test('throws FormatException for invalid algorithm', () {
      final json = {
        'algorithm': 'invalid_algo',
        'salt': standardSalt,
        'iterations': 1000,
      };

      final matcher = isA<FormatException>().having(
        (e) => e.message,
        'message',
        contains('Invalid or unknown KDF algorithm'),
      );

      expect(() => KdfMetadata.fromJson(json), throwsA(matcher));
    });

    test('throws FormatException for invalid base64 salt', () {
      final json = {
        'algorithm': 'argon2id',
        'salt': 'invalid base64!',
        'iterations': 1000,
      };

      final matcher = isA<FormatException>().having(
        (e) => e.message,
        'message',
        contains('Invalid base64 encoding for salt'),
      );

      expect(() => KdfMetadata.fromJson(json), throwsA(matcher));
    });

    test('throws FormatException when integer fields are not integers', () {
      final json = {
        'algorithm': 'argon2id',
        'salt': standardSalt,
        'iterations': '1000', // String instead of int
      };

      final matcher = isA<FormatException>().having(
        (e) => e.message,
        'message',
        contains('iterations must be an integer'),
      );

      expect(() => KdfMetadata.fromJson(json), throwsA(matcher));
    });

    test('throws FormatException for negative iterations value', () {
      final json = {
        'algorithm': 'argon2id',
        'salt': standardSalt,
        'iterations': -1,
      };

      final matcher = isA<FormatException>().having(
        (e) => e.message,
        'message',
        contains('iterations must be non-negative'),
      );

      expect(() => KdfMetadata.fromJson(json), throwsA(matcher));
    });

    test('throws FormatException for negative memory value', () {
      final json = {
        'algorithm': 'argon2id',
        'salt': standardSalt,
        'iterations': 1000,
        'memory': -1,
      };

      final matcher = isA<FormatException>().having(
        (e) => e.message,
        'message',
        contains('memory must be non-negative'),
      );

      expect(() => KdfMetadata.fromJson(json), throwsA(matcher));
    });

    test('throws FormatException for negative parallelism value', () {
      final json = {
        'algorithm': 'argon2id',
        'salt': standardSalt,
        'iterations': 1000,
        'memory': 1024,
        'parallelism': -1,
      };

      final matcher = isA<FormatException>().having(
        (e) => e.message,
        'message',
        contains('parallelism must be non-negative'),
      );

      expect(() => KdfMetadata.fromJson(json), throwsA(matcher));
    });

    test('accepts zero values for iterations, memory, and parallelism', () {
      final json = {
        'algorithm': 'argon2id',
        'salt': standardSalt,
        'iterations': 0,
        'memory': 0,
        'parallelism': 0,
      };

      final metadata = KdfMetadata.fromJson(json);

      expect(metadata.iterations, 0);
      expect(metadata.memory, 0);
      expect(metadata.parallelism, 0);
    });

    test('accepts empty salt byte array', () {
      final emptySalt = base64Encode(Uint8List.fromList([]));
      final json = {
        'algorithm': 'argon2id',
        'salt': emptySalt,
        'iterations': 1000,
      };

      final metadata = KdfMetadata.fromJson(json);

      expect(metadata.salt, isEmpty);
    });

    test('throws FormatException for null algorithm field', () {
      final json = <String, dynamic>{
        'algorithm': null,
        'salt': standardSalt,
        'iterations': 1000,
      };

      final matcher = isA<FormatException>().having(
        (e) => e.message,
        'message',
        contains('Invalid or unknown KDF algorithm'),
      );

      expect(() => KdfMetadata.fromJson(json), throwsA(matcher));
    });

    test('throws FormatException for null salt field', () {
      final json = <String, dynamic>{
        'algorithm': 'argon2id',
        'salt': null,
        'iterations': 1000,
      };

      final matcher = isA<FormatException>().having(
        (e) => e.message,
        'message',
        contains('Invalid base64 encoding for salt'),
      );

      expect(() => KdfMetadata.fromJson(json), throwsA(matcher));
    });

    test('throws FormatException for null iterations field', () {
      final json = <String, dynamic>{
        'algorithm': 'argon2id',
        'salt': standardSalt,
        'iterations': null,
      };

      final matcher = isA<FormatException>().having(
        (e) => e.message,
        'message',
        contains('iterations must be an integer'),
      );

      expect(() => KdfMetadata.fromJson(json), throwsA(matcher));
    });

    test('uses default value for null memory field', () {
      final json = <String, dynamic>{
        'algorithm': 'argon2id',
        'salt': standardSalt,
        'iterations': 1000,
        'memory': null,
      };

      // null ?? 0 evaluates to 0, so this should succeed
      final metadata = KdfMetadata.fromJson(json);

      expect(metadata.memory, 0);
    });

    test('uses default value for null parallelism field', () {
      final json = <String, dynamic>{
        'algorithm': 'argon2id',
        'salt': standardSalt,
        'iterations': 1000,
        'memory': 1024,
        'parallelism': null,
      };

      // null ?? 0 evaluates to 0, so this should succeed
      final metadata = KdfMetadata.fromJson(json);

      expect(metadata.parallelism, 0);
    });

    test('accepts large integer values', () {
      final json = {
        'algorithm': 'argon2id',
        'salt': standardSalt,
        'iterations': 9007199254740991, // Max safe integer in JS
        'memory': 1073741824, // 1 GB
        'parallelism': 256,
      };

      final metadata = KdfMetadata.fromJson(json);

      expect(metadata.iterations, 9007199254740991);
      expect(metadata.memory, 1073741824);
      expect(metadata.parallelism, 256);
    });

    test('throws FormatException for first missing required key when multiple are missing', () {
      final json = <String, dynamic>{
        // 'algorithm' missing
        // 'salt' missing
        // 'iterations' missing
      };

      // Implementation checks keys in order: algorithm, salt, iterations
      // and throws on the first missing key
      final matcher = isA<FormatException>().having(
        (e) => e.message,
        'message',
        contains('Missing required key: algorithm'),
      );

      expect(() => KdfMetadata.fromJson(json), throwsA(matcher));
    });

    test('throws FormatException for missing salt when algorithm is present', () {
      final json = <String, dynamic>{
        'algorithm': 'argon2id',
        // 'salt' missing
        // 'iterations' missing
      };

      final matcher = isA<FormatException>().having(
        (e) => e.message,
        'message',
        contains('Missing required key: salt'),
      );

      expect(() => KdfMetadata.fromJson(json), throwsA(matcher));
    });
  });
}
