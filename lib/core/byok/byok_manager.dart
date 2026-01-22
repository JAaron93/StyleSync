import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../storage/secure_storage_service.dart';
import '../storage/secure_storage_service_impl.dart';
import 'api_key_validator.dart';
import 'byok_storage_keys.dart';
import 'cloud_backup_service.dart';
import 'models/api_key_config.dart';
import 'models/byok_error.dart';
import 'models/validation_result.dart';

/// Result type for BYOK operations.
///
/// Represents either a successful result with a value of type [T],
/// or a failure with a [BYOKError].
sealed class Result<T> {
  const Result();

  /// Returns true if this is a successful result.
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a failure result.
  bool get isFailure => this is Failure<T>;

  /// Returns the value if successful, or null if failure.
  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  /// Returns the error if failure, or null if successful.
  BYOKError? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final error) => error,
      };

  /// Transforms the value if successful, otherwise returns the failure.
  Result<U> map<U>(U Function(T value) transform) => switch (this) {
        Success<T>(:final value) => Success(transform(value)),
        Failure<T>(:final error) => Failure(error),
      };

  /// Transforms the value if successful using an async function.
  Future<Result<U>> mapAsync<U>(Future<U> Function(T value) transform) async =>
      switch (this) {
        Success<T>(:final value) => Success(await transform(value)),
        Failure<T>(:final error) => Failure(error),
      };
}

/// Successful result containing a value.
class Success<T> extends Result<T> {
  /// The successful value.
  final T value;

  const Success(this.value);

  @override
  String toString() => 'Success($value)';
}

/// Failure result containing an error.
class Failure<T> extends Result<T> {
  /// The error that caused the failure.
  final BYOKError error;

  const Failure(this.error);

  @override
  String toString() => 'Failure($error)';
}

/// Manages API key lifecycle: storage, retrieval, and deletion.
///
/// This service orchestrates the complete lifecycle of user-provided API keys,
/// including validation, secure storage, and optional cloud backup.
abstract class BYOKManager {
  /// Stores an API key after validation.
  ///
  /// Returns [Success] if the key was stored successfully.
  /// Returns [Failure] with [BYOKError] if validation or storage fails.
  ///
  /// The key is validated before storage using [APIKeyValidator].
  /// If cloud backup is enabled, the backup is updated automatically.
  Future<Result<void>> storeAPIKey(String apiKey, String projectId);

  /// Retrieves the stored API key configuration.
  ///
  /// Returns [Success] with [APIKeyConfig] if a key is stored.
  /// Returns [Failure] with [NotFoundError] if no key is stored.
  Future<Result<APIKeyConfig>> getAPIKey();

  /// Deletes the stored API key and optionally the cloud backup.
  ///
  /// [deleteCloudBackup]: If true, also deletes the cloud backup.
  ///
  /// Returns [Success] if deletion was successful.
  /// Returns [Failure] if deletion fails.
  Future<Result<void>> deleteAPIKey({bool deleteCloudBackup = false});

  /// Updates an existing API key.
  ///
  /// The new key is validated before replacing the old key.
  /// If cloud backup is enabled and [passphrase] is provided, the backup
  /// is re-encrypted with the new key. If re-encryption fails, cloud backup
  /// is disabled locally but the key update still succeeds.
  Future<Result<void>> updateAPIKey(String newApiKey, String projectId,
      {String? passphrase});

  /// Enables cloud backup with the given passphrase.
  ///
  /// Derives an encryption key from the passphrase and encrypts
  /// the current API key configuration for cloud storage.
  Future<Result<void>> enableCloudBackup(String passphrase);

  /// Disables cloud backup and optionally deletes the backup.
  ///
  /// [deleteBackup]: If true, deletes the existing cloud backup.
  Future<Result<void>> disableCloudBackup({bool deleteBackup = true});

  /// Restores an API key from cloud backup.
  ///
  /// Fetches the encrypted backup and decrypts it using the passphrase.
  Future<Result<APIKeyConfig>> restoreFromCloudBackup(String passphrase);

  /// Checks if an API key is currently stored.
  Future<bool> hasStoredKey();

  /// Checks if cloud backup is enabled.
  Future<bool> isCloudBackupEnabled();

  /// Re-encrypts the cloud backup with a new passphrase.
  ///
  /// Requires the old passphrase to decrypt and the new passphrase
  /// to re-encrypt. Does not require re-entry of the API key.
  Future<Result<void>> rotateBackupPassphrase(
    String oldPassphrase,
    String newPassphrase,
  );
}

/// Default implementation of [BYOKManager].
///
/// Uses [SecureStorageService] for local storage, [APIKeyValidator]
/// for key validation, and [CloudBackupService] for cloud backup operations.
class BYOKManagerImpl implements BYOKManager {
  /// The secure storage service for persisting API key configuration.
  final SecureStorageService _secureStorage;

  /// The API key validator for format and functional validation.
  final APIKeyValidator _apiKeyValidator;

  /// The cloud backup service for encrypted cloud backup operations.
  final CloudBackupService? _cloudBackupService;

  /// UUID generator for creating idempotency keys.
  final Uuid _uuid;

  /// Creates a new [BYOKManagerImpl] instance.
  ///
  /// [secureStorage] - The secure storage service for persisting data.
  /// [apiKeyValidator] - The validator for API key validation.
  /// [cloudBackupService] - Optional cloud backup service for backup operations.
  /// [uuid] - Optional UUID generator (defaults to a new Uuid instance).
  BYOKManagerImpl({
    required SecureStorageService secureStorage,
    required APIKeyValidator apiKeyValidator,
    CloudBackupService? cloudBackupService,
    Uuid? uuid,
  })  : _secureStorage = secureStorage,
        _apiKeyValidator = apiKeyValidator,
        _cloudBackupService = cloudBackupService,
        _uuid = uuid ?? const Uuid();

  @override
  Future<Result<void>> storeAPIKey(String apiKey, String projectId) async {
    // Normalize input up-front to ensure consistent validation and storage
    final trimmedApiKey = apiKey.trim();

    // Step 1: Validate format
    final formatResult = _apiKeyValidator.validateFormat(trimmedApiKey);
    if (formatResult is ValidationFailure) {
      return Failure(ValidationError(
        formatResult.message,
        formatResult,
      ));
    }

    // Step 2: Validate functionality
    final functionalResult = await _apiKeyValidator.validateFunctionality(
      trimmedApiKey,
      projectId,
    );
    if (functionalResult is ValidationFailure) {
      return Failure(ValidationError(
        functionalResult.message,
        functionalResult,
      ));
    }

    // Step 3: Create API key configuration
    final now = DateTime.now();
    final idempotencyKey = _generateIdempotencyKey();
    final config = APIKeyConfig(
      apiKey: trimmedApiKey,
      projectId: projectId,
      createdAt: now,
      lastValidated: now,
      cloudBackupEnabled: false,
      idempotencyKey: idempotencyKey,
    );

    // Step 4: Store in secure storage
    try {
      final jsonString = jsonEncode(config.toJson());
      await _secureStorage.write(BYOKStorageKeys.apiKeyConfig, jsonString);
      return const Success(null);
    } catch (e) {
      return Failure(StorageError(
        'Failed to store API key configuration',
        originalError: e,
      ));
    }
  }

  @override
  Future<Result<APIKeyConfig>> getAPIKey() async {
    try {
      final jsonString =
          await _secureStorage.read(BYOKStorageKeys.apiKeyConfig);
      if (jsonString == null) {
        return const Failure(NotFoundError());
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final config = APIKeyConfig.fromJson(json);
      return Success(config);
    } on FormatException catch (e) {
      return Failure(StorageError(
        'Failed to parse stored API key configuration',
        originalError: e,
      ));
    } catch (e) {
      return Failure(StorageError(
        'Failed to retrieve API key configuration',
        originalError: e,
      ));
    }
  }

  @override
  Future<Result<void>> deleteAPIKey({bool deleteCloudBackup = false}) async {
    try {
      // Check if key exists first
      final existingKey =
          await _secureStorage.read(BYOKStorageKeys.apiKeyConfig);
      if (existingKey == null) {
        return const Failure(NotFoundError());
      }

      // Delete the API key configuration
      await _secureStorage.delete(BYOKStorageKeys.apiKeyConfig);

      // Delete cloud backup related keys
      if (deleteCloudBackup) {
        await _secureStorage.delete(BYOKStorageKeys.cloudBackupEnabled);
        await _secureStorage.delete(BYOKStorageKeys.backupPassphraseHash);

        // Delete from CloudBackupService if available
        if (_cloudBackupService != null) {
          final deleteResult = await _cloudBackupService.deleteBackup();
          if (deleteResult.isFailure) {
            // Log the error but don't fail the operation
            // The local key is already deleted
          }
        }
      }

      return const Success(null);
    } catch (e) {
      return Failure(StorageError(
        'Failed to delete API key configuration',
        originalError: e,
      ));
    }
  }

  @override
  Future<Result<void>> updateAPIKey(String newApiKey, String projectId,
      {String? passphrase}) async {
    // Normalize input up-front to ensure consistent validation and storage
    final trimmedApiKey = newApiKey.trim();

    // Step 1: Validate format
    final formatResult = _apiKeyValidator.validateFormat(trimmedApiKey);
    if (formatResult is ValidationFailure) {
      return Failure(ValidationError(
        formatResult.message,
        formatResult,
      ));
    }

    // Step 2: Validate functionality
    final functionalResult = await _apiKeyValidator.validateFunctionality(
      trimmedApiKey,
      projectId,
    );
    if (functionalResult is ValidationFailure) {
      return Failure(ValidationError(
        functionalResult.message,
        functionalResult,
      ));
    }

    // Step 3: Get existing configuration to preserve metadata
    final existingResult = await getAPIKey();
    final existingConfig = existingResult.valueOrNull;

    // Step 4: Create updated configuration
    final now = DateTime.now();
    final idempotencyKey = _generateIdempotencyKey();
    final updatedConfig = APIKeyConfig(
      apiKey: trimmedApiKey,
      projectId: projectId,
      createdAt: existingConfig?.createdAt ?? now,
      lastValidated: now,
      cloudBackupEnabled: existingConfig?.cloudBackupEnabled ?? false,
      idempotencyKey: idempotencyKey,
    );

    // Step 5: Store in secure storage
    try {
      final jsonString = jsonEncode(updatedConfig.toJson());
      await _secureStorage.write(BYOKStorageKeys.apiKeyConfig, jsonString);
    } catch (e) {
      return Failure(StorageError(
        'Failed to update API key configuration',
        originalError: e,
      ));
    }

    // Step 6: Re-encrypt cloud backup if enabled
    if (_cloudBackupService != null &&
        (existingConfig?.cloudBackupEnabled ?? false)) {
      if (passphrase != null) {
        // Attempt to update cloud backup with new key
        final backupResult = await _cloudBackupService.createOrUpdateBackup(
          updatedConfig,
          passphrase,
        );
        if (backupResult.isFailure) {
          // Disable cloud backup locally (don't delete the backup data)
          final disabledConfig = updatedConfig.copyWith(cloudBackupEnabled: false);
          try {
            final disabledJsonString = jsonEncode(disabledConfig.toJson());
            await _secureStorage.write(
                BYOKStorageKeys.apiKeyConfig, disabledJsonString);
            await _secureStorage.delete(BYOKStorageKeys.cloudBackupEnabled);
          } catch (_) {
            // Ignore storage errors during cleanup
          }
          print('[BYOKManager] WARNING: Cloud backup re-encryption failed during '
              'key update. Cloud backup has been disabled. '
              'Error: ${backupResult.errorOrNull?.message}');
        }
      } else {
        // No passphrase provided but backup is enabled
        print('[BYOKManager] WARNING: Cloud backup is enabled but no passphrase '
            'provided for key update. Cloud backup was not updated with the new key.');
      }
    }

    // Return success - the key update itself succeeded
    return const Success(null);
  }

  @override
  Future<Result<void>> enableCloudBackup(String passphrase) async {
    // Verify CloudBackupService is available
    if (_cloudBackupService == null) {
      return const Failure(BackupError(
        'Cloud backup service is not available',
        BackupErrorType.storageError,
      ));
    }

    // Verify an API key exists
    final keyResult = await getAPIKey();
    if (keyResult.isFailure) {
      return Failure(keyResult.errorOrNull!);
    }

    try {
      final config = keyResult.valueOrNull!;

      // Create or update the cloud backup
      final backupResult = await _cloudBackupService.createOrUpdateBackup(
        config,
        passphrase,
      );
      if (backupResult.isFailure) {
        return Failure(backupResult.errorOrNull!);
      }

      // Update the config to mark cloud backup as enabled
      final updatedConfig = config.copyWith(cloudBackupEnabled: true);
      final jsonString = jsonEncode(updatedConfig.toJson());
      await _secureStorage.write(BYOKStorageKeys.apiKeyConfig, jsonString);

      // Store cloud backup enabled flag
      await _secureStorage.write(BYOKStorageKeys.cloudBackupEnabled, 'true');

      return const Success(null);
    } catch (e) {
      return Failure(StorageError(
        'Failed to enable cloud backup',
        originalError: e,
      ));
    }
  }

  @override
  Future<Result<void>> disableCloudBackup({bool deleteBackup = true}) async {
    try {
      // Get current config
      final keyResult = await getAPIKey();
      if (keyResult.isSuccess) {
        // Update the config to mark cloud backup as disabled
        final config = keyResult.valueOrNull!;
        final updatedConfig = config.copyWith(cloudBackupEnabled: false);
        final jsonString = jsonEncode(updatedConfig.toJson());
        await _secureStorage.write(BYOKStorageKeys.apiKeyConfig, jsonString);
      }

      // Remove cloud backup enabled flag
      await _secureStorage.delete(BYOKStorageKeys.cloudBackupEnabled);
      await _secureStorage.delete(BYOKStorageKeys.backupPassphraseHash);

      // Delete from CloudBackupService if requested and available
      if (deleteBackup && _cloudBackupService != null) {
        final deleteResult = await _cloudBackupService.deleteBackup();
        if (deleteResult.isFailure) {
          // Log the error but don't fail the operation
          // The local state is already updated
        }
      }

      return const Success(null);
    } catch (e) {
      return Failure(StorageError(
        'Failed to disable cloud backup',
        originalError: e,
      ));
    }
  }

  @override
  Future<Result<APIKeyConfig>> restoreFromCloudBackup(String passphrase) async {
    // Verify CloudBackupService is available
    if (_cloudBackupService == null) {
      return const Failure(BackupError(
        'Cloud backup service is not available',
        BackupErrorType.storageError,
      ));
    }

    // Restore from cloud backup
    final restoreResult = await _cloudBackupService.restoreBackup(passphrase);
    if (restoreResult.isFailure) {
      return Failure(restoreResult.errorOrNull!);
    }

    // Store the restored config locally
    try {
      final config = restoreResult.valueOrNull!;
      final jsonString = jsonEncode(config.toJson());
      await _secureStorage.write(BYOKStorageKeys.apiKeyConfig, jsonString);

      // Update cloud backup enabled flag if the config indicates it was enabled
      if (config.cloudBackupEnabled) {
        await _secureStorage.write(BYOKStorageKeys.cloudBackupEnabled, 'true');
      }

      return Success(config);
    } catch (e) {
      return Failure(StorageError(
        'Failed to store restored API key configuration',
        originalError: e,
      ));
    }
  }

  @override
  Future<bool> hasStoredKey() async {
    try {
      final jsonString =
          await _secureStorage.read(BYOKStorageKeys.apiKeyConfig);
      return jsonString != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isCloudBackupEnabled() async {
    try {
      final enabled =
          await _secureStorage.read(BYOKStorageKeys.cloudBackupEnabled);
      return enabled == 'true';
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Result<void>> rotateBackupPassphrase(
    String oldPassphrase,
    String newPassphrase,
  ) async {
    // Verify CloudBackupService is available
    if (_cloudBackupService == null) {
      return const Failure(BackupError(
        'Cloud backup service is not available',
        BackupErrorType.storageError,
      ));
    }

    // Delegate to CloudBackupService
    return _cloudBackupService.rotatePassphrase(oldPassphrase, newPassphrase);
  }

  /// Generates a unique idempotency key using UUID v4 and timestamp.
  String _generateIdempotencyKey() {
    final uuid = _uuid.v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$uuid-$timestamp';
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

/// Provider for [SecureStorageService].
///
/// Creates a singleton instance of [SecureStorageServiceImpl].
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageServiceImpl();
});

/// Provider for [APIKeyValidator].
///
/// Creates a singleton instance of [APIKeyValidatorImpl].
final apiKeyValidatorProvider = Provider<APIKeyValidator>((ref) {
  return APIKeyValidatorImpl();
});

/// Provider for [BYOKManager].
///
/// Creates a [BYOKManagerImpl] instance with injected dependencies.
final byokManagerProvider = Provider<BYOKManager>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final apiKeyValidator = ref.watch(apiKeyValidatorProvider);
  final cloudBackupService = ref.watch(cloudBackupServiceProvider);

  return BYOKManagerImpl(
    secureStorage: secureStorage,
    apiKeyValidator: apiKeyValidator,
    cloudBackupService: cloudBackupService,
  );
});
