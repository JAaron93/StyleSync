import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:stylesync/core/byok/byok_manager.dart';
import 'package:stylesync/core/byok/models/api_key_config.dart';
import 'package:stylesync/core/byok/models/byok_error.dart';
import 'package:stylesync/core/byok/models/cloud_backup_blob.dart';
import 'package:stylesync/core/crypto/kdf_metadata.dart';

void main() {
  group('CloudBackupBlob', () {
    test('toJson and fromJson round-trip', () {
      final salt = Uint8List.fromList(List.generate(16, (i) => i));
      final metadata = KdfMetadata(
        algorithm: KdfAlgorithm.argon2id,
        salt: salt,
        iterations: 3,
        memory: 65536,
        parallelism: 4,
      );

      final now = DateTime.utc(2025, 1, 21, 22, 0, 0);
      final blob = CloudBackupBlob(
        version: 1,
        kdfMetadata: metadata,
        encryptedData: base64Encode([1, 2, 3, 4, 5]),
        createdAt: now,
        updatedAt: now,
      );

      final json = blob.toJson();
      final restored = CloudBackupBlob.fromJson(json);

      expect(restored.version, equals(blob.version));
      expect(restored.encryptedData, equals(blob.encryptedData));
      expect(restored.createdAt, equals(blob.createdAt));
      expect(restored.updatedAt, equals(blob.updatedAt));
      expect(restored.kdfMetadata.algorithm, equals(metadata.algorithm));
      expect(restored.kdfMetadata.iterations, equals(metadata.iterations));
      expect(restored.kdfMetadata.memory, equals(metadata.memory));
      expect(restored.kdfMetadata.parallelism, equals(metadata.parallelism));
      expect(restored.kdfMetadata.salt, equals(metadata.salt));
    });

    test('fromJson throws on unsupported version', () {
      final json = {
        'version': 999,
        'kdf': {
          'algorithm': 'argon2id',
          'salt': base64Encode([1, 2, 3, 4]),
          'iterations': 3,
          'memory': 65536,
          'parallelism': 4,
        },
        'encrypted_data': base64Encode([1, 2, 3]),
        'created_at': '2025-01-21T22:00:00.000Z',
        'updated_at': '2025-01-21T22:00:00.000Z',
      };

      expect(
        () => CloudBackupBlob.fromJson(json),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('not supported'),
        )),
      );
    });

    test('fromJson throws on missing required keys', () {
      final json = {
        'version': 1,
        // missing 'kdf', 'encrypted_data', etc.
      };

      expect(
        () => CloudBackupBlob.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromJson throws on empty encrypted_data', () {
      final json = {
        'version': 1,
        'kdf': {
          'algorithm': 'argon2id',
          'salt': base64Encode([1, 2, 3, 4]),
          'iterations': 3,
          'memory': 65536,
          'parallelism': 4,
        },
        'encrypted_data': '',
        'created_at': '2025-01-21T22:00:00.000Z',
        'updated_at': '2025-01-21T22:00:00.000Z',
      };

      expect(
        () => CloudBackupBlob.fromJson(json),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('non-empty'),
        )),
      );
    });

    test('fromJson throws on unknown KDF algorithm', () {
      final json = {
        'version': 1,
        'kdf': {
          'algorithm': 'unknown_algorithm',
          'salt': base64Encode([1, 2, 3, 4]),
          'iterations': 3,
          'memory': 65536,
          'parallelism': 4,
        },
        'encrypted_data': base64Encode([1, 2, 3]),
        'created_at': '2025-01-21T22:00:00.000Z',
        'updated_at': '2025-01-21T22:00:00.000Z',
      };

      expect(
        () => CloudBackupBlob.fromJson(json),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          anyOf([
            contains('Invalid or unknown KDF algorithm'), // From KdfMetadata.fromJson
            contains('Unsupported or unknown KDF algorithm'), // From our additional validation
          ]),
        )),
      );
    });

    group('copyWith', () {
      late Uint8List salt;
      late KdfMetadata metadata;
      late DateTime now;
      late CloudBackupBlob blob;

      setUp(() {
        salt = Uint8List.fromList(List.generate(16, (i) => i));
        metadata = KdfMetadata(
          algorithm: KdfAlgorithm.argon2id,
          salt: salt,
          iterations: 3,
          memory: 65536,
          parallelism: 4,
        );
        now = DateTime.utc(2025, 1, 21, 22, 0, 0);
        blob = CloudBackupBlob(
          version: 1,
          kdfMetadata: metadata,
          encryptedData: base64Encode([1, 2, 3, 4, 5]),
          createdAt: now,
          updatedAt: now,
        );
      });

      test('copyWith(updatedAt:) only updates updatedAt', () {
        final later = DateTime.utc(2025, 1, 22, 10, 0, 0);
        final updatedWithTime = blob.copyWith(updatedAt: later);

        expect(updatedWithTime.version, equals(blob.version),
            reason: 'version should remain unchanged');
        expect(updatedWithTime.encryptedData, equals(blob.encryptedData),
            reason: 'encryptedData should remain unchanged');
        expect(updatedWithTime.createdAt, equals(blob.createdAt),
            reason: 'createdAt should remain unchanged');
        expect(updatedWithTime.kdfMetadata, equals(blob.kdfMetadata),
            reason: 'kdfMetadata should remain unchanged');
        expect(updatedWithTime.updatedAt, equals(later),
            reason: 'updatedAt should be updated to new value');
      });

      test('copyWith(encryptedData:) only updates encryptedData', () {
        final newEncryptedData = base64Encode([10, 20, 30, 40, 50]);
        final updatedWithData = blob.copyWith(encryptedData: newEncryptedData);

        expect(updatedWithData.encryptedData, equals(newEncryptedData),
            reason: 'encryptedData should be updated to new value');
        expect(updatedWithData.version, equals(blob.version),
            reason: 'version should remain unchanged');
        expect(updatedWithData.createdAt, equals(blob.createdAt),
            reason: 'createdAt should remain unchanged');
        expect(updatedWithData.updatedAt, equals(blob.updatedAt),
            reason: 'updatedAt should remain unchanged');
        expect(updatedWithData.kdfMetadata, equals(blob.kdfMetadata),
            reason: 'kdfMetadata should remain unchanged');
      });

      test('copyWith(version:) only updates version', () {
        const newVersion = 2;
        final updatedWithVersion = blob.copyWith(version: newVersion);

        expect(updatedWithVersion.version, equals(newVersion),
            reason: 'version should be updated to new value');
        expect(updatedWithVersion.encryptedData, equals(blob.encryptedData),
            reason: 'encryptedData should remain unchanged');
        expect(updatedWithVersion.createdAt, equals(blob.createdAt),
            reason: 'createdAt should remain unchanged');
        expect(updatedWithVersion.updatedAt, equals(blob.updatedAt),
            reason: 'updatedAt should remain unchanged');
        expect(updatedWithVersion.kdfMetadata, equals(blob.kdfMetadata),
            reason: 'kdfMetadata should remain unchanged');
      });

      test('copyWith(kdfMetadata:) only updates kdfMetadata', () {
        final newSalt = Uint8List.fromList(List.generate(16, (i) => i + 100));
        final newMetadata = KdfMetadata(
          algorithm: KdfAlgorithm.pbkdf2,
          salt: newSalt,
          iterations: 100000,
          memory: 0,
          parallelism: 1,
        );
        final updatedWithMetadata = blob.copyWith(kdfMetadata: newMetadata);

        expect(updatedWithMetadata.kdfMetadata, equals(newMetadata),
            reason: 'kdfMetadata should be updated to new value');
        expect(updatedWithMetadata.kdfMetadata.algorithm, equals(KdfAlgorithm.pbkdf2),
            reason: 'kdfMetadata.algorithm should be updated');
        expect(updatedWithMetadata.kdfMetadata.salt, equals(newSalt),
            reason: 'kdfMetadata.salt should be updated');
        expect(updatedWithMetadata.kdfMetadata.iterations, equals(100000),
            reason: 'kdfMetadata.iterations should be updated');
        expect(updatedWithMetadata.version, equals(blob.version),
            reason: 'version should remain unchanged');
        expect(updatedWithMetadata.encryptedData, equals(blob.encryptedData),
            reason: 'encryptedData should remain unchanged');
        expect(updatedWithMetadata.createdAt, equals(blob.createdAt),
            reason: 'createdAt should remain unchanged');
        expect(updatedWithMetadata.updatedAt, equals(blob.updatedAt),
            reason: 'updatedAt should remain unchanged');
      });

      test('copyWith(createdAt:) only updates createdAt', () {
        // Though typically createdAt shouldn't change
        final newCreatedAt = DateTime.utc(2024, 12, 1, 0, 0, 0);
        final updatedWithCreatedAt = blob.copyWith(createdAt: newCreatedAt);

        expect(updatedWithCreatedAt.createdAt, equals(newCreatedAt),
            reason: 'createdAt should be updated to new value');
        expect(updatedWithCreatedAt.version, equals(blob.version),
            reason: 'version should remain unchanged');
        expect(updatedWithCreatedAt.encryptedData, equals(blob.encryptedData),
            reason: 'encryptedData should remain unchanged');
        expect(updatedWithCreatedAt.updatedAt, equals(blob.updatedAt),
            reason: 'updatedAt should remain unchanged');
        expect(updatedWithCreatedAt.kdfMetadata, equals(blob.kdfMetadata),
            reason: 'kdfMetadata should remain unchanged');
      });
    });
  });

  group('Result type', () {
    test('Result type works correctly', () {
      const success = Success<int>(42);
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(success.valueOrNull, equals(42));
      expect(success.errorOrNull, isNull);

      const failure = Failure<int>(NotFoundError());
      expect(failure.isSuccess, isFalse);
      expect(failure.isFailure, isTrue);
      expect(failure.valueOrNull, isNull);
      expect(failure.errorOrNull, isA<NotFoundError>());
    });

    test('Result.map transforms success values', () {
      const success = Success<int>(21);
      final mapped = success.map((v) => v * 2);
      expect(mapped.valueOrNull, equals(42));
    });

    test('Result.map preserves failure', () {
      const failure = Failure<int>(NotFoundError());
      final mapped = failure.map((v) => v * 2);
      expect(mapped.isFailure, isTrue);
      expect(mapped.errorOrNull, isA<NotFoundError>());
    });
  });

  group('APIKeyConfig backup integration', () {
    test('APIKeyConfig can be serialized for backup', () {
      final config = APIKeyConfig(
        apiKey: 'AIzaTestKey12345678901234567890123',
        projectId: 'test-project',
        createdAt: DateTime.utc(2025, 1, 21, 22, 0, 0),
        lastValidated: DateTime.utc(2025, 1, 21, 22, 0, 0),
        cloudBackupEnabled: true,
        idempotencyKey: 'test-idempotency-key',
      );

      final json = config.toJson();
      final jsonString = jsonEncode(json);
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      // Verify we can convert back
      final decodedString = utf8.decode(bytes);
      final decodedJson = jsonDecode(decodedString) as Map<String, dynamic>;
      final restored = APIKeyConfig.fromJson(decodedJson);

      expect(restored.apiKey, equals(config.apiKey));
      expect(restored.projectId, equals(config.projectId));
      expect(restored.cloudBackupEnabled, equals(config.cloudBackupEnabled));
      expect(restored.createdAt, equals(config.createdAt));
      expect(restored.lastValidated, equals(config.lastValidated));
      expect(restored.idempotencyKey, equals(config.idempotencyKey));
    });
  });

  group('BackupError types', () {
    test('BackupError types are distinct', () {
      const notFound = BackupError('Not found', BackupErrorType.notFound);
      const wrongPassphrase =
          BackupError('Wrong passphrase', BackupErrorType.wrongPassphrase);
      const corrupted = BackupError('Corrupted', BackupErrorType.corrupted);
      const networkError =
          BackupError('Network error', BackupErrorType.networkError);
      const storageError =
          BackupError('Storage error', BackupErrorType.storageError);

      expect(notFound.type, equals(BackupErrorType.notFound));
      expect(wrongPassphrase.type, equals(BackupErrorType.wrongPassphrase));
      expect(corrupted.type, equals(BackupErrorType.corrupted));
      expect(networkError.type, equals(BackupErrorType.networkError));
      expect(storageError.type, equals(BackupErrorType.storageError));
    });
  });
}
