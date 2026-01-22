/// Unit tests for BYOK operations (Task 4.5)
///
/// Tests cover:
/// - API key storage and retrieval (Req 2.10, 2.18)
/// - Cloud backup enable/disable (Req 2.15, 2.17, 2.19)
/// - Sign-out options (Req 2.20, 2.21, 2.22)
/// - Error handling
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:stylesync/core/byok/api_key_validator.dart';
import 'package:stylesync/core/byok/byok_manager.dart';
import 'package:stylesync/core/byok/byok_storage_keys.dart';
import 'package:stylesync/core/byok/cloud_backup_service.dart';
import 'package:stylesync/core/byok/models/api_key_config.dart';
import 'package:stylesync/core/byok/models/byok_error.dart';
import 'package:stylesync/core/byok/models/validation_result.dart';
import 'package:stylesync/core/storage/secure_storage_service.dart';

// =============================================================================
// Mock Implementations
// =============================================================================

/// Mock HTTP client for testing API validation
class MockHttpClient extends http.BaseClient {
  final int statusCode;
  final String responseBody;
  final bool shouldTimeout;
  final bool shouldThrowSocketException;
  int callCount = 0;

  MockHttpClient({
    this.statusCode = 200,
    this.responseBody = '{"models": []}',
    this.shouldTimeout = false,
    this.shouldThrowSocketException = false,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    callCount++;

    if (shouldTimeout) {
      throw TimeoutException('Request timed out');
    }

    if (shouldThrowSocketException) {
      throw const SocketException('Network unreachable');
    }

    final response = http.Response(responseBody, statusCode);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      statusCode,
      headers: response.headers,
    );
  }
}

/// In-memory mock implementation of SecureStorageService
class MockSecureStorage implements SecureStorageService {
  final Map<String, String> _storage = {};
  bool shouldThrowOnWrite = false;
  bool shouldThrowOnRead = false;
  bool shouldThrowOnDelete = false;

  @override
  Future<void> write(String key, String value) async {
    if (shouldThrowOnWrite) {
      throw Exception('Storage write error');
    }
    _storage[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    if (shouldThrowOnRead) {
      throw Exception('Storage read error');
    }
    return _storage[key];
  }

  @override
  Future<void> delete(String key) async {
    if (shouldThrowOnDelete) {
      throw Exception('Storage delete error');
    }
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    if (shouldThrowOnDelete) {
      throw Exception('Storage delete error');
    }
    _storage.clear();
  }

  @override
  SecureStorageBackend get backend => SecureStorageBackend.software;

  @override
  bool get requiresBiometric => false;

  /// Check if a key exists in storage
  bool containsKey(String key) => _storage.containsKey(key);

  /// Get all stored keys
  Set<String> get keys => _storage.keys.toSet();

  /// Clear storage for test isolation
  void clear() => _storage.clear();
}

/// Mock CloudBackupService for testing backup operations
class MockCloudBackupService implements CloudBackupService {
  bool backupEnabled = false;
  APIKeyConfig? storedConfig;
  String? storedPassphrase;
  bool shouldFailOnCreate = false;
  bool shouldFailOnRestore = false;
  bool shouldFailOnDelete = false;
  BackupErrorType failureType = BackupErrorType.storageError;
  int createCallCount = 0;
  int deleteCallCount = 0;
  int restoreCallCount = 0;

  @override
  Future<Result<void>> createOrUpdateBackup(
    APIKeyConfig config,
    String passphrase, {
    DateTime? createdAt,
  }) async {
    createCallCount++;
    if (shouldFailOnCreate) {
      return Failure(BackupError('Backup creation failed', failureType));
    }
    storedConfig = config;
    storedPassphrase = passphrase;
    backupEnabled = true;
    return const Success(null);
  }

  @override
  Future<Result<APIKeyConfig>> restoreBackup(String passphrase) async {
    restoreCallCount++;
    if (shouldFailOnRestore) {
      return Failure(BackupError('Backup restore failed', failureType));
    }
    if (storedConfig == null) {
      return const Failure(
          BackupError('Backup not found', BackupErrorType.notFound));
    }
    if (passphrase != storedPassphrase) {
      return const Failure(
          BackupError('Wrong passphrase', BackupErrorType.wrongPassphrase));
    }
    return Success(storedConfig!);
  }

  @override
  Future<Result<void>> deleteBackup() async {
    deleteCallCount++;
    if (shouldFailOnDelete) {
      return Failure(BackupError('Backup deletion failed', failureType));
    }
    storedConfig = null;
    storedPassphrase = null;
    backupEnabled = false;
    return const Success(null);
  }

  @override
  Future<Result<bool>> backupExists() async {
    return Success(storedConfig != null);
  }

  @override
  Future<Result<void>> rotatePassphrase(
    String oldPassphrase,
    String newPassphrase,
  ) async {
    if (storedConfig == null) {
      return const Failure(
          BackupError('Backup not found', BackupErrorType.notFound));
    }
    if (oldPassphrase != storedPassphrase) {
      return const Failure(
          BackupError('Wrong passphrase', BackupErrorType.wrongPassphrase));
    }
    storedPassphrase = newPassphrase;
    return const Success(null);
  }

  @override
  Future<Result<bool>> verifyPassphrase(String passphrase) async {
    if (storedConfig == null) {
      return const Failure(
          BackupError('Backup not found', BackupErrorType.notFound));
    }
    return Success(passphrase == storedPassphrase);
  }

  void reset() {
    backupEnabled = false;
    storedConfig = null;
    storedPassphrase = null;
    shouldFailOnCreate = false;
    shouldFailOnRestore = false;
    shouldFailOnDelete = false;
    failureType = BackupErrorType.storageError;
    createCallCount = 0;
    deleteCallCount = 0;
    restoreCallCount = 0;
  }
}

// =============================================================================
// Test Helpers
// =============================================================================

/// Valid API key for testing (format: AIza + 35 alphanumeric chars = 39 total)
const String validApiKey = 'AIzaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

/// Another valid API key for update tests (39 chars total)
const String validApiKey2 = 'AIzabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

/// Invalid API key (wrong prefix)
const String invalidApiKey = 'XXXXaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

/// Valid project ID
const String validProjectId = 'test-project-123';

/// Test passphrase for cloud backup
const String testPassphrase = 'secure-passphrase-123';

/// Creates a BYOKManager with mock dependencies for testing
BYOKManagerImpl createTestManager({
  MockSecureStorage? storage,
  MockHttpClient? httpClient,
  MockCloudBackupService? cloudBackupService,
}) {
  final mockStorage = storage ?? MockSecureStorage();
  final mockClient = httpClient ?? MockHttpClient(statusCode: 200);
  final validator = APIKeyValidatorImpl(httpClient: mockClient);

  return BYOKManagerImpl(
    secureStorage: mockStorage,
    apiKeyValidator: validator,
    cloudBackupService: cloudBackupService,
  );
}

// =============================================================================
// Unit Tests
// =============================================================================

void main() {
  // ===========================================================================
  // 1. API Key Storage and Retrieval Tests
  // ===========================================================================

  group('API Key Storage and Retrieval', () {
    group('Store API key successfully', () {
      test('stores valid API key in secure storage', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        final result = await manager.storeAPIKey(validApiKey, validProjectId);

        expect(result, isA<Success<void>>(),
            reason: 'Valid API key should be stored successfully');
        expect(mockStorage.containsKey(BYOKStorageKeys.apiKeyConfig), isTrue,
            reason: 'API key config should be stored in secure storage');
      });

      test('validates format before storing', () async {
        final mockClient = MockHttpClient(statusCode: 200);
        final manager = createTestManager(httpClient: mockClient);

        await manager.storeAPIKey(validApiKey, validProjectId);

        expect(mockClient.callCount, equals(1),
            reason: 'Should make API call to validate functionality');
      });

      test('stores API key with correct metadata', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        await manager.storeAPIKey(validApiKey, validProjectId);
        final result = await manager.getAPIKey();

        expect(result, isA<Success<APIKeyConfig>>());
        final config = result.valueOrNull!;
        expect(config.apiKey, equals(validApiKey));
        expect(config.projectId, equals(validProjectId));
        expect(config.cloudBackupEnabled, isFalse,
            reason: 'Cloud backup should be disabled by default (Req 2.17)');
        expect(config.idempotencyKey, isNotEmpty);
      });

      test('API key is device-specific and not transmitted (Req 2.10)',
          () async {
        final mockStorage = MockSecureStorage();
        final mockClient = MockHttpClient(statusCode: 200);
        final manager = createTestManager(
          storage: mockStorage,
          httpClient: mockClient,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);

        // Verify key is stored locally
        expect(mockStorage.containsKey(BYOKStorageKeys.apiKeyConfig), isTrue,
            reason:
                'API key should be stored in device-specific secure storage');

        // Verify only validation call was made (not a storage call to backend)
        expect(mockClient.callCount, equals(1),
            reason:
                'Only validation API call should be made, no backend storage');
      });
    });

    group('Retrieve stored API key', () {
      test('retrieves stored API key successfully', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        await manager.storeAPIKey(validApiKey, validProjectId);
        final result = await manager.getAPIKey();

        expect(result, isA<Success<APIKeyConfig>>());
        expect(result.valueOrNull!.apiKey, equals(validApiKey));
        expect(result.valueOrNull!.projectId, equals(validProjectId));
      });

      test('hasStoredKey returns true when key exists', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        await manager.storeAPIKey(validApiKey, validProjectId);
        final hasKey = await manager.hasStoredKey();

        expect(hasKey, isTrue);
      });

      test('hasStoredKey returns false when no key exists', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        final hasKey = await manager.hasStoredKey();

        expect(hasKey, isFalse);
      });
    });

    group('Update existing API key (Req 2.18)', () {
      test('replaces old key with new key in secure storage', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        // Store initial key
        await manager.storeAPIKey(validApiKey, validProjectId);

        // Update with new key
        final updateResult =
            await manager.updateAPIKey(validApiKey2, validProjectId);

        expect(updateResult, isA<Success<void>>(), reason: 'Update should succeed');

        // Verify new key is stored
        final getResult = await manager.getAPIKey();
        expect(getResult.valueOrNull!.apiKey, equals(validApiKey2),
            reason: 'Old key should be replaced with new key (Req 2.18)');
      });

      test('preserves createdAt timestamp on update', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        await manager.storeAPIKey(validApiKey, validProjectId);
        final originalConfig = (await manager.getAPIKey()).valueOrNull!;

        await manager.updateAPIKey(validApiKey2, validProjectId);
        final updatedConfig = (await manager.getAPIKey()).valueOrNull!;

        expect(updatedConfig.createdAt, equals(originalConfig.createdAt),
            reason: 'Original creation timestamp should be preserved');
        expect(
            !updatedConfig.lastValidated.isBefore(originalConfig.lastValidated),
            isTrue,
            reason: 'lastValidated should be updated (at or after original)');
      });

      test('validates new key before replacing', () async {
        final mockClient = MockHttpClient(statusCode: 401);
        final mockStorage = MockSecureStorage();

        // First store with successful validation
        final successClient = MockHttpClient(statusCode: 200);
        final initialManager = BYOKManagerImpl(
          secureStorage: mockStorage,
          apiKeyValidator: APIKeyValidatorImpl(httpClient: successClient),
        );
        await initialManager.storeAPIKey(validApiKey, validProjectId);

        // Try to update with failing validation
        final updateManager = BYOKManagerImpl(
          secureStorage: mockStorage,
          apiKeyValidator: APIKeyValidatorImpl(httpClient: mockClient),
        );
        final updateResult =
            await updateManager.updateAPIKey(validApiKey2, validProjectId);

        expect(updateResult, isA<Failure<void>>(),
            reason: 'Update should fail if new key validation fails');

        // Original key should still be stored
        final getResult = await updateManager.getAPIKey();
        expect(getResult.valueOrNull!.apiKey, equals(validApiKey),
            reason: 'Original key should remain if update fails');
      });
    });

    group('Delete API key removes from storage (Req 2.22)', () {
      test('deletes API key from secure storage', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        await manager.storeAPIKey(validApiKey, validProjectId);
        final deleteResult = await manager.deleteAPIKey();

        expect(deleteResult, isA<Success<void>>());
        expect(mockStorage.containsKey(BYOKStorageKeys.apiKeyConfig), isFalse,
            reason:
                'API key should be removed from secure storage (Req 2.22)');
      });

      test('hasStoredKey returns false after deletion', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.deleteAPIKey();
        final hasKey = await manager.hasStoredKey();

        expect(hasKey, isFalse);
      });

      test('removes all traces from storage (Req 2.22)', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        // Store key and enable backup
        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);

        // Delete with cloud backup removal
        await manager.deleteAPIKey(deleteCloudBackup: true);

        expect(mockStorage.containsKey(BYOKStorageKeys.apiKeyConfig), isFalse,
            reason: 'API key config should be removed');
        expect(
            mockStorage.containsKey(BYOKStorageKeys.cloudBackupEnabled), isFalse,
            reason: 'Cloud backup flag should be removed');
        expect(mockBackup.deleteCallCount, equals(1),
            reason: 'Cloud backup should be deleted (Req 2.22)');
      });
    });

    group('Retrieve non-existent key returns error', () {
      test('returns NotFoundError when no key is stored', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        final result = await manager.getAPIKey();

        expect(result, isA<Failure<APIKeyConfig>>());
        expect(result.errorOrNull, isA<NotFoundError>());
      });

      test('returns NotFoundError when deleting non-existent key', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        final result = await manager.deleteAPIKey();

        expect(result, isA<Failure<void>>());
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });
  });

  // ===========================================================================
  // 2. Cloud Backup Enable/Disable Tests
  // ===========================================================================

  group('Cloud Backup Enable/Disable', () {
    group('Enable cloud backup encrypts and uploads', () {
      test('enables cloud backup successfully', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        final result = await manager.enableCloudBackup(testPassphrase);

        expect(result, isA<Success<void>>());
        expect(mockBackup.createCallCount, equals(1),
            reason: 'Should call createOrUpdateBackup');
        expect(mockBackup.storedConfig, isNotNull,
            reason: 'Config should be stored in backup');
      });

      test('updates cloudBackupEnabled flag in config', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);

        final config = (await manager.getAPIKey()).valueOrNull!;
        expect(config.cloudBackupEnabled, isTrue);
      });

      test('stores cloud backup enabled flag in secure storage', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);

        expect(
            mockStorage.containsKey(BYOKStorageKeys.cloudBackupEnabled), isTrue);
      });

      test('fails if no API key is stored', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        final result = await manager.enableCloudBackup(testPassphrase);

        expect(result, isA<Failure<void>>());
        expect(mockBackup.createCallCount, equals(0),
            reason: 'Should not attempt backup without API key');
      });

      test('fails if cloud backup service is not available', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: null,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        final result = await manager.enableCloudBackup(testPassphrase);

        expect(result, isA<Failure<void>>());
        expect(result.errorOrNull, isA<BackupError>());
      });
    });

    group('Disable cloud backup removes from cloud', () {
      test('disables cloud backup and deletes backup', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);
        final result = await manager.disableCloudBackup(deleteBackup: true);

        expect(result, isA<Success<void>>());
        expect(mockBackup.deleteCallCount, equals(1),
            reason: 'Should delete cloud backup');
      });

      test('updates cloudBackupEnabled flag to false', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);
        await manager.disableCloudBackup();

        final config = (await manager.getAPIKey()).valueOrNull!;
        expect(config.cloudBackupEnabled, isFalse);
      });

      test('removes cloud backup enabled flag from storage', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);
        await manager.disableCloudBackup();

        expect(mockStorage.containsKey(BYOKStorageKeys.cloudBackupEnabled),
            isFalse);
      });

      test('can disable without deleting backup', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);
        await manager.disableCloudBackup(deleteBackup: false);

        expect(mockBackup.deleteCallCount, equals(0),
            reason: 'Should not delete backup when deleteBackup is false');
      });
    });

    group('Re-enable cloud backup after disable', () {
      test('can re-enable cloud backup', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);
        await manager.disableCloudBackup();
        final result = await manager.enableCloudBackup(testPassphrase);

        expect(result, isA<Success<void>>());
        expect(mockBackup.createCallCount, equals(2),
            reason: 'Should create backup twice');
      });
    });

    group('Cloud backup is optional (Req 2.17)', () {
      test('cloud backup is disabled by default', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        await manager.storeAPIKey(validApiKey, validProjectId);
        final isEnabled = await manager.isCloudBackupEnabled();

        expect(isEnabled, isFalse,
            reason:
                'Cloud backup should be optional and disabled by default (Req 2.17)');
      });

      test('config has cloudBackupEnabled false by default', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        await manager.storeAPIKey(validApiKey, validProjectId);
        final config = (await manager.getAPIKey()).valueOrNull!;

        expect(config.cloudBackupEnabled, isFalse,
            reason:
                'Cloud backup should be clearly labeled as optional (Req 2.17)');
      });
    });
  });

  // ===========================================================================
  // 3. Sign-Out Options Tests
  // ===========================================================================

  group('Sign-Out Options', () {
    group('Sign out and remove API key (Req 2.20)', () {
      test('removes API key from secure storage', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        await manager.storeAPIKey(validApiKey, validProjectId);
        final result = await manager.deleteAPIKey(deleteCloudBackup: false);

        expect(result, isA<Success<void>>());
        expect(await manager.hasStoredKey(), isFalse,
            reason: 'API key should be removed on sign out (Req 2.20)');
      });
    });

    group('API key persists until explicitly deleted (Req 2.20)', () {
      test('persists API key after store', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        await manager.storeAPIKey(validApiKey, validProjectId);

        // Verify key persists - sign-out with "keep key" option means
        // the app simply does not call deleteAPIKey()
        expect(await manager.hasStoredKey(), isTrue,
            reason: 'API key should remain on device until explicitly deleted (Req 2.20)');
      });
    });

    group('Sign out and remove cloud backup (Req 2.21)', () {
      test('removes cloud backup when enabled and user chooses', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);
        final result = await manager.deleteAPIKey(deleteCloudBackup: true);

        expect(result, isA<Success<void>>());
        expect(mockBackup.deleteCallCount, equals(1),
            reason:
                'Cloud backup should be removed when user chooses (Req 2.21)');
      });

      test('preserves cloud backup when user chooses', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);
        await manager.deleteAPIKey(deleteCloudBackup: false);

        expect(mockBackup.deleteCallCount, equals(0),
            reason: 'Cloud backup should be preserved when user chooses');
      });
    });
  });

  // ===========================================================================
  // 4. Key Update with Cloud Backup Tests
  // ===========================================================================

  group('Key Update with Cloud Backup', () {
    group('Update API key re-encrypts cloud backup (Req 2.15, 2.19)', () {
      test('preserves cloud backup enabled state on update', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);
        await manager.updateAPIKey(validApiKey2, validProjectId);

        final config = (await manager.getAPIKey()).valueOrNull!;
        expect(config.cloudBackupEnabled, isTrue,
            reason: 'Cloud backup enabled state should be preserved on update');
      });

      // Note: Full re-encryption on update is marked as TODO in byok_manager.dart
      // This test documents the expected behavior per Req 2.15 and 2.19
      test('updates stored key when cloud backup is enabled', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);
        await manager.updateAPIKey(validApiKey2, validProjectId);

        final config = (await manager.getAPIKey()).valueOrNull!;
        expect(config.apiKey, equals(validApiKey2),
            reason: 'API key should be updated');
      });
    });

    group('Update API key when cloud backup disabled', () {
      test('updates key without affecting backup service', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.updateAPIKey(validApiKey2, validProjectId);

        expect(mockBackup.createCallCount, equals(0),
            reason: 'Should not interact with backup when disabled');
        final config = (await manager.getAPIKey()).valueOrNull!;
        expect(config.apiKey, equals(validApiKey2));
      });
    });

    group('Update API key with passphrase re-encrypts cloud backup', () {
      test('re-encrypts backup when passphrase provided and backup enabled', () async {
        // Scenario 1: Happy Path - Backup Re-encryption Succeeds
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        // Store initial key and enable backup
        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);
        expect(mockBackup.createCallCount, equals(1),
            reason: 'Initial backup should be created');

        // Update key with passphrase
        final result = await manager.updateAPIKey(
          validApiKey2,
          validProjectId,
          passphrase: testPassphrase,
        );

        expect(result, isA<Success<void>>(),
            reason: 'Key update should succeed');
        expect(mockBackup.createCallCount, equals(2),
            reason: 'Backup should be re-encrypted with new key');

        // Verify the new key is stored
        final config = (await manager.getAPIKey()).valueOrNull!;
        expect(config.apiKey, equals(validApiKey2));
        expect(config.cloudBackupEnabled, isTrue,
            reason: 'Cloud backup should remain enabled after successful re-encryption');
      });

      test('disables backup locally when re-encryption fails', () async {
        // Scenario 2: Backup Re-encryption Fails - Fallback to Disable
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        // Store initial key and enable backup
        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);

        // Make backup creation fail for the update
        mockBackup.shouldFailOnCreate = true;

        // Update key with passphrase
        final result = await manager.updateAPIKey(
          validApiKey2,
          validProjectId,
          passphrase: testPassphrase,
        );

        expect(result, isA<Success<void>>(),
            reason: 'Key update should still succeed even if backup fails');

        // Verify the new key is stored
        final config = (await manager.getAPIKey()).valueOrNull!;
        expect(config.apiKey, equals(validApiKey2),
            reason: 'New key should be stored');
        expect(config.cloudBackupEnabled, isFalse,
            reason: 'Cloud backup should be disabled after re-encryption failure');

        // Verify cloud backup enabled flag is removed from storage
        expect(mockStorage.containsKey(BYOKStorageKeys.cloudBackupEnabled), isFalse,
            reason: 'Cloud backup enabled flag should be removed from storage');
      });

      test('does not re-encrypt when no passphrase provided but backup enabled', () async {
        // Scenario 3: No Passphrase Provided - Warning Logged
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        // Store initial key and enable backup
        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);
        final initialCreateCount = mockBackup.createCallCount;

        // Update key WITHOUT passphrase
        final result = await manager.updateAPIKey(validApiKey2, validProjectId);

        expect(result, isA<Success<void>>(),
            reason: 'Key update should succeed');
        expect(mockBackup.createCallCount, equals(initialCreateCount),
            reason: 'Backup should NOT be re-encrypted without passphrase');

        // Verify the new key is stored but backup state is preserved
        final config = (await manager.getAPIKey()).valueOrNull!;
        expect(config.apiKey, equals(validApiKey2));
        expect(config.cloudBackupEnabled, isTrue,
            reason: 'Cloud backup enabled state should be preserved');
      });

      test('does not attempt backup when cloud backup disabled', () async {
        // Scenario 4: Cloud Backup Not Enabled - No Backup Operations
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        // Store initial key but do NOT enable backup
        await manager.storeAPIKey(validApiKey, validProjectId);
        expect(mockBackup.createCallCount, equals(0));

        // Update key with passphrase (should not trigger backup)
        final result = await manager.updateAPIKey(
          validApiKey2,
          validProjectId,
          passphrase: testPassphrase,
        );

        expect(result, isA<Success<void>>(),
            reason: 'Key update should succeed');
        expect(mockBackup.createCallCount, equals(0),
            reason: 'No backup operations should occur when backup is disabled');

        final config = (await manager.getAPIKey()).valueOrNull!;
        expect(config.apiKey, equals(validApiKey2));
        expect(config.cloudBackupEnabled, isFalse);
      });

      test('does not attempt backup when no CloudBackupService injected', () async {
        // Scenario 5: No CloudBackupService Injected - No Backup Operations
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: null, // No backup service
        );

        // Store initial key
        await manager.storeAPIKey(validApiKey, validProjectId);

        // Update key with passphrase (should not crash)
        final result = await manager.updateAPIKey(
          validApiKey2,
          validProjectId,
          passphrase: testPassphrase,
        );

        expect(result, isA<Success<void>>(),
            reason: 'Key update should succeed without backup service');

        final config = (await manager.getAPIKey()).valueOrNull!;
        expect(config.apiKey, equals(validApiKey2));
      });

      test('does not attempt backup when key update fails', () async {
        // Scenario 6: Key Update Fails - No Backup Operations Attempted
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();

        // First store with successful validation
        final successClient = MockHttpClient(statusCode: 200);
        final initialManager = BYOKManagerImpl(
          secureStorage: mockStorage,
          apiKeyValidator: APIKeyValidatorImpl(httpClient: successClient),
          cloudBackupService: mockBackup,
        );
        await initialManager.storeAPIKey(validApiKey, validProjectId);
        await initialManager.enableCloudBackup(testPassphrase);
        final initialCreateCount = mockBackup.createCallCount;

        // Try to update with failing validation
        final failClient = MockHttpClient(statusCode: 401);
        final updateManager = BYOKManagerImpl(
          secureStorage: mockStorage,
          apiKeyValidator: APIKeyValidatorImpl(httpClient: failClient),
          cloudBackupService: mockBackup,
        );

        final result = await updateManager.updateAPIKey(
          validApiKey2,
          validProjectId,
          passphrase: testPassphrase,
        );

        expect(result, isA<Failure<void>>(),
            reason: 'Key update should fail due to validation');
        expect(mockBackup.createCallCount, equals(initialCreateCount),
            reason: 'No backup operations should be attempted when key update fails');

        // Original key should still be stored
        final config = (await updateManager.getAPIKey()).valueOrNull!;
        expect(config.apiKey, equals(validApiKey),
            reason: 'Original key should remain');
        expect(config.cloudBackupEnabled, isTrue,
            reason: 'Cloud backup state should be unchanged');
      });

      test('handles storage error during backup disable gracefully', () async {
        // Edge case: Storage error during cleanup after backup failure
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        // Store initial key and enable backup
        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);

        // Make backup creation fail
        mockBackup.shouldFailOnCreate = true;
        // Also make storage write fail during cleanup to test error handling
        mockStorage.shouldThrowOnWrite = true;

        // Update key with passphrase
        final result = await manager.updateAPIKey(
          validApiKey2,
          validProjectId,
          passphrase: testPassphrase,
        );

        // Should still succeed because key update itself worked
        expect(result, isA<Success<void>>(),
            reason: 'Key update should succeed even with cleanup errors');

        // The new key should be stored (from the first write before backup attempt)
        final config = (await manager.getAPIKey()).valueOrNull!;
        expect(config.apiKey, equals(validApiKey2));
      });

      test('backup receives updated config with new key', () async {
        // Verify the backup service receives the correct updated config
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);

        await manager.updateAPIKey(
          validApiKey2,
          validProjectId,
          passphrase: testPassphrase,
        );

        // Verify the backup service received the updated config
        expect(mockBackup.storedConfig, isNotNull);
        expect(mockBackup.storedConfig!.apiKey, equals(validApiKey2),
            reason: 'Backup should contain the new API key');
        expect(mockBackup.storedPassphrase, equals(testPassphrase),
            reason: 'Backup should use the provided passphrase');
      });
    });
  });

  // ===========================================================================
  // 5. Error Handling Tests
  // ===========================================================================

  group('Error Handling', () {
    group('Storage errors are handled gracefully', () {
      test('handles storage write error', () async {
        final mockStorage = MockSecureStorage();
        mockStorage.shouldThrowOnWrite = true;
        final manager = createTestManager(storage: mockStorage);

        final result = await manager.storeAPIKey(validApiKey, validProjectId);

        expect(result, isA<Failure<void>>());
        expect(result.errorOrNull, isA<StorageError>());
      });

      test('handles storage read error', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        await manager.storeAPIKey(validApiKey, validProjectId);
        mockStorage.shouldThrowOnRead = true;

        final result = await manager.getAPIKey();

        expect(result, isA<Failure<APIKeyConfig>>());
        expect(result.errorOrNull, isA<StorageError>());
      });

      test('handles storage delete error', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        await manager.storeAPIKey(validApiKey, validProjectId);
        mockStorage.shouldThrowOnDelete = true;

        final result = await manager.deleteAPIKey();

        expect(result, isA<Failure<void>>());
        expect(result.errorOrNull, isA<StorageError>());
      });
    });

    group('Cloud backup errors do not affect local storage', () {
      test('local storage succeeds even if backup fails', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        mockBackup.shouldFailOnCreate = true;
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        // Store key first (should succeed)
        final storeResult =
            await manager.storeAPIKey(validApiKey, validProjectId);
        expect(storeResult, isA<Success<void>>());

        // Enable backup (should fail)
        final backupResult = await manager.enableCloudBackup(testPassphrase);
        expect(backupResult, isA<Failure<void>>());

        // Key should still be stored locally
        expect(await manager.hasStoredKey(), isTrue,
            reason: 'Local storage should not be affected by backup failure');
      });

      test('delete succeeds even if cloud backup delete fails', () async {
        final mockStorage = MockSecureStorage();
        final mockBackup = MockCloudBackupService();
        final manager = createTestManager(
          storage: mockStorage,
          cloudBackupService: mockBackup,
        );

        await manager.storeAPIKey(validApiKey, validProjectId);
        await manager.enableCloudBackup(testPassphrase);

        // Make backup deletion fail
        mockBackup.shouldFailOnDelete = true;

        // Delete should still succeed for local storage
        final result = await manager.deleteAPIKey(deleteCloudBackup: true);

        // The operation succeeds because local deletion worked
        // (cloud backup failure is logged but doesn't fail the operation)
        expect(result, isA<Success<void>>());
        expect(await manager.hasStoredKey(), isFalse,
            reason: 'Local key should be deleted even if cloud backup fails');
      });
    });

    group('Validation errors prevent storage', () {
      test('invalid format key is not stored', () async {
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(storage: mockStorage);

        final result = await manager.storeAPIKey(invalidApiKey, validProjectId);

        expect(result, isA<Failure<void>>());
        expect(result.errorOrNull, isA<ValidationError>());
        expect(await manager.hasStoredKey(), isFalse,
            reason: 'Invalid key should not be stored');
      });

      test('API validation failure prevents storage', () async {
        final mockClient = MockHttpClient(statusCode: 401);
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(
          storage: mockStorage,
          httpClient: mockClient,
        );

        final result = await manager.storeAPIKey(validApiKey, validProjectId);

        expect(result, isA<Failure<void>>());
        expect(result.errorOrNull, isA<ValidationError>());
        expect(await manager.hasStoredKey(), isFalse,
            reason: 'Key with failed API validation should not be stored');
      });

      test('network error during validation prevents storage', () async {
        final mockClient = MockHttpClient(shouldTimeout: true);
        final mockStorage = MockSecureStorage();
        final manager = createTestManager(
          storage: mockStorage,
          httpClient: mockClient,
        );

        final result = await manager.storeAPIKey(validApiKey, validProjectId);

        expect(result, isA<Failure<void>>());
        expect(result.errorOrNull, isA<ValidationError>());
        expect(await manager.hasStoredKey(), isFalse);
      });
    });
  });

  // ===========================================================================
  // 6. Restore from Cloud Backup Tests
  // ===========================================================================

  group('Restore from Cloud Backup', () {
    test('restores API key from cloud backup successfully', () async {
      final mockStorage = MockSecureStorage();
      final mockBackup = MockCloudBackupService();
      final manager = createTestManager(
        storage: mockStorage,
        cloudBackupService: mockBackup,
      );

      // Store and backup key
      await manager.storeAPIKey(validApiKey, validProjectId);
      await manager.enableCloudBackup(testPassphrase);

      // Clear local storage to simulate new device
      mockStorage.clear();
      expect(await manager.hasStoredKey(), isFalse);

      // Restore from backup
      final result = await manager.restoreFromCloudBackup(testPassphrase);

      expect(result, isA<Success<APIKeyConfig>>());
      expect(result.valueOrNull!.apiKey, equals(validApiKey));
      expect(await manager.hasStoredKey(), isTrue,
          reason: 'Restored key should be stored locally');
    });

    test('fails with wrong passphrase', () async {
      final mockStorage = MockSecureStorage();
      final mockBackup = MockCloudBackupService();
      final manager = createTestManager(
        storage: mockStorage,
        cloudBackupService: mockBackup,
      );

      await manager.storeAPIKey(validApiKey, validProjectId);
      await manager.enableCloudBackup(testPassphrase);
      mockStorage.clear();

      final result = await manager.restoreFromCloudBackup('wrong-passphrase');

      expect(result, isA<Failure<APIKeyConfig>>());
      expect(result.errorOrNull, isA<BackupError>());
      final error = result.errorOrNull as BackupError;
      expect(error.type, equals(BackupErrorType.wrongPassphrase));
    });

    test('fails when no backup exists', () async {
      final mockStorage = MockSecureStorage();
      final mockBackup = MockCloudBackupService();
      final manager = createTestManager(
        storage: mockStorage,
        cloudBackupService: mockBackup,
      );

      final result = await manager.restoreFromCloudBackup(testPassphrase);

      expect(result, isA<Failure<APIKeyConfig>>());
      expect(result.errorOrNull, isA<BackupError>());
      final error = result.errorOrNull as BackupError;
      expect(error.type, equals(BackupErrorType.notFound));
    });

    test('fails when cloud backup service is not available', () async {
      final mockStorage = MockSecureStorage();
      final manager = createTestManager(
        storage: mockStorage,
        cloudBackupService: null,
      );

      final result = await manager.restoreFromCloudBackup(testPassphrase);

      expect(result, isA<Failure<APIKeyConfig>>());
      expect(result.errorOrNull, isA<BackupError>());
    });
  });

  // ===========================================================================
  // 7. Passphrase Rotation Tests (Req 2.15)
  // ===========================================================================

  group('Passphrase Rotation (Req 2.15)', () {
    test('rotates passphrase successfully', () async {
      final mockStorage = MockSecureStorage();
      final mockBackup = MockCloudBackupService();
      final manager = createTestManager(
        storage: mockStorage,
        cloudBackupService: mockBackup,
      );

      await manager.storeAPIKey(validApiKey, validProjectId);
      await manager.enableCloudBackup(testPassphrase);

      const newPassphrase = 'new-secure-passphrase';
      final result =
          await manager.rotateBackupPassphrase(testPassphrase, newPassphrase);

      expect(result, isA<Success<void>>());
      expect(mockBackup.storedPassphrase, equals(newPassphrase),
          reason: 'Passphrase should be updated (Req 2.15)');
    });

    test('fails with wrong old passphrase', () async {
      final mockStorage = MockSecureStorage();
      final mockBackup = MockCloudBackupService();
      final manager = createTestManager(
        storage: mockStorage,
        cloudBackupService: mockBackup,
      );

      await manager.storeAPIKey(validApiKey, validProjectId);
      await manager.enableCloudBackup(testPassphrase);

      final result = await manager.rotateBackupPassphrase(
          'wrong-passphrase', 'new-passphrase');

      expect(result, isA<Failure<void>>());
      expect(result.errorOrNull, isA<BackupError>());
      final error = result.errorOrNull as BackupError;
      expect(error.type, equals(BackupErrorType.wrongPassphrase));
    });

    test('fails when no backup exists', () async {
      final mockStorage = MockSecureStorage();
      final mockBackup = MockCloudBackupService();
      final manager = createTestManager(
        storage: mockStorage,
        cloudBackupService: mockBackup,
      );

      final result = await manager.rotateBackupPassphrase(
          testPassphrase, 'new-passphrase');

      expect(result, isA<Failure<void>>());
      expect(result.errorOrNull, isA<BackupError>());
    });

    test('fails when cloud backup service is not available', () async {
      final mockStorage = MockSecureStorage();
      final manager = createTestManager(
        storage: mockStorage,
        cloudBackupService: null,
      );

      final result = await manager.rotateBackupPassphrase(
          testPassphrase, 'new-passphrase');

      expect(result, isA<Failure<void>>());
      expect(result.errorOrNull, isA<BackupError>());
    });
  });

  // ===========================================================================
  // 8. Result Type Tests
  // ===========================================================================

  group('Result Type', () {
    test('Success contains value', () {
      const success = Success<int>(42);
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(success.valueOrNull, equals(42));
      expect(success.errorOrNull, isNull);
    });

    test('Failure contains error', () {
      const failure = Failure<int>(NotFoundError());
      expect(failure.isSuccess, isFalse);
      expect(failure.isFailure, isTrue);
      expect(failure.valueOrNull, isNull);
      expect(failure.errorOrNull, isA<NotFoundError>());
    });

    test('map transforms success value', () {
      const success = Success<int>(21);
      final mapped = success.map((v) => v * 2);
      expect(mapped.valueOrNull, equals(42));
    });

    test('map preserves failure', () {
      const failure = Failure<int>(NotFoundError());
      final mapped = failure.map((v) => v * 2);
      expect(mapped.isFailure, isTrue);
      expect(mapped.errorOrNull, isA<NotFoundError>());
    });

    test('mapAsync transforms success value', () async {
      const success = Success<int>(21);
      final mapped = await success.mapAsync((v) async => v * 2);
      expect(mapped.valueOrNull, equals(42));
    });

    test('mapAsync preserves failure', () async {
      const failure = Failure<int>(NotFoundError());
      final mapped = await failure.mapAsync((v) async => v * 2);
      expect(mapped.isFailure, isTrue);
      expect(mapped.errorOrNull, isA<NotFoundError>());
    });
  });

  // ===========================================================================
  // 9. isCloudBackupEnabled Tests
  // ===========================================================================

  group('isCloudBackupEnabled', () {
    test('returns false when flag not set', () async {
      final mockStorage = MockSecureStorage();
      final manager = createTestManager(storage: mockStorage);

      final isEnabled = await manager.isCloudBackupEnabled();

      expect(isEnabled, isFalse);
    });

    test('returns true when flag is set to true', () async {
      final mockStorage = MockSecureStorage();
      final mockBackup = MockCloudBackupService();
      final manager = createTestManager(
        storage: mockStorage,
        cloudBackupService: mockBackup,
      );

      await manager.storeAPIKey(validApiKey, validProjectId);
      await manager.enableCloudBackup(testPassphrase);

      final isEnabled = await manager.isCloudBackupEnabled();

      expect(isEnabled, isTrue);
    });

    test('returns false after disabling backup', () async {
      final mockStorage = MockSecureStorage();
      final mockBackup = MockCloudBackupService();
      final manager = createTestManager(
        storage: mockStorage,
        cloudBackupService: mockBackup,
      );

      await manager.storeAPIKey(validApiKey, validProjectId);
      await manager.enableCloudBackup(testPassphrase);
      await manager.disableCloudBackup();

      final isEnabled = await manager.isCloudBackupEnabled();

      expect(isEnabled, isFalse);
    });

    test('returns false on storage error', () async {
      final mockStorage = MockSecureStorage();
      final manager = createTestManager(storage: mockStorage);

      mockStorage.shouldThrowOnRead = true;

      final isEnabled = await manager.isCloudBackupEnabled();

      expect(isEnabled, isFalse,
          reason: 'Should return false on error, not throw');
    });
  });
}
