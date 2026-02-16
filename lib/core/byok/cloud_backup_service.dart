import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_service.dart';
import '../auth/auth_providers.dart';
import '../crypto/encryption_service.dart';
import '../crypto/key_derivation_service.dart';
import 'byok_manager.dart';
import 'models/api_key_config.dart';
import 'models/byok_error.dart';
import 'models/cloud_backup_blob.dart';

/// Manages encrypted cloud backup of API keys.
///
/// This service handles the encryption, upload, download, and deletion
/// of API key backups in Firebase Storage. All data is encrypted client-side
/// using a key derived from the user's passphrase.
abstract class CloudBackupService {
  /// Creates or updates an encrypted backup of the API key configuration.
  ///
  /// Derives an encryption key from the passphrase using [KeyDerivationService],
  /// encrypts the configuration using [EncryptionService], and uploads to
  /// Firebase Storage at `users/{userId}/api_key_backup.json`.
  ///
  /// If [createdAt] is provided, it will be used as the backup's creation
  /// timestamp. This is useful during passphrase rotation to preserve the
  /// original creation timestamp. If not provided, the existing backup's
  /// createdAt will be used (if one exists), otherwise the current time.
  ///
  /// Returns [Success] if the backup was created/updated successfully.
  /// Returns [Failure] with [BackupError] if the operation fails.
  Future<Result<void>> createOrUpdateBackup(
    APIKeyConfig config,
    String passphrase, {
    DateTime? createdAt,
  });

  /// Restores an API key configuration from cloud backup.
  ///
  /// Downloads the encrypted backup from Firebase Storage, derives the
  /// decryption key from the passphrase, and decrypts the configuration.
  ///
  /// Returns [Success] with [APIKeyConfig] if restoration succeeds.
  /// Returns [Failure] with [BackupError] if:
  /// - Backup doesn't exist ([BackupErrorType.notFound])
  /// - Passphrase is incorrect ([BackupErrorType.wrongPassphrase])
  /// - Backup is corrupted ([BackupErrorType.corrupted])
  /// - Network error occurs ([BackupErrorType.networkError])
  Future<Result<APIKeyConfig>> restoreBackup(String passphrase);

  /// Deletes the cloud backup.
  ///
  /// Returns [Success] if deletion was successful or backup didn't exist.
  /// Returns [Failure] with [BackupError] if deletion fails.
  Future<Result<void>> deleteBackup();

  /// Checks if a cloud backup exists for the current user.
  ///
  /// Returns [Success] with true if a backup exists.
  /// Returns [Success] with false if no backup exists (object-not-found).
  /// Returns [Failure] with [BackupError] if:
  /// - User is not authenticated ([BackupErrorType.storageError])
  /// - Permission denied or other Firebase errors ([BackupErrorType.storageError])
  /// - Network error occurs ([BackupErrorType.networkError])
  Future<Result<bool>> backupExists();

  /// Re-encrypts the backup with a new passphrase.
  ///
  /// This is used for passphrase rotation. The backup is decrypted with
  /// the old passphrase and re-encrypted with the new passphrase.
  ///
  /// Returns [Success] if rotation was successful.
  /// Returns [Failure] with [BackupError] if:
  /// - Old passphrase is incorrect ([BackupErrorType.wrongPassphrase])
  /// - Backup doesn't exist ([BackupErrorType.notFound])
  /// - Network error occurs ([BackupErrorType.networkError])
  Future<Result<void>> rotatePassphrase(
    String oldPassphrase,
    String newPassphrase,
  );

  /// Verifies that the provided passphrase can decrypt the backup.
  ///
  /// Returns [Success] with true if the passphrase is correct.
  /// Returns [Success] with false if the passphrase is incorrect.
  /// Returns [Failure] if the backup doesn't exist or a network error occurs.
  Future<Result<bool>> verifyPassphrase(String passphrase);
}

/// Default implementation of [CloudBackupService].
///
/// Uses Firebase Storage for cloud storage, [KeyDerivationService] for
/// key derivation, and [EncryptionService] for encryption/decryption.
class CloudBackupServiceImpl implements CloudBackupService {
  /// The Firebase Storage instance.
  final FirebaseStorage _storage;

  /// The auth service for getting the current user ID.
  final AuthService _authService;

  /// The key derivation service for deriving encryption keys.
  final KeyDerivationService _keyDerivationService;

  /// The encryption service for encrypting/decrypting data.
  final EncryptionService _encryptionService;

  /// Creates a new [CloudBackupServiceImpl] instance.
  CloudBackupServiceImpl({
    required FirebaseStorage storage,
    required AuthService authService,
    required KeyDerivationService keyDerivationService,
    required EncryptionService encryptionService,
  })  : _storage = storage,
        _authService = authService,
        _keyDerivationService = keyDerivationService,
        _encryptionService = encryptionService;

  /// Gets the storage path for the current user's backup.
  String _getBackupPath() {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      throw StateError('No authenticated user');
    }
    return 'users/$userId/api_key_backup.json';
  }

  /// Gets the temporary storage path for passphrase rotation.
  String _getTempBackupPath() {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      throw StateError('No authenticated user');
    }
    return 'users/$userId/api_key_backup_temp.json';
  }

  /// Checks if the given error is a network-related error.
  ///
  /// Returns `true` for:
  /// - [SocketException] (connection failures, DNS errors, etc.)
  /// - [HttpException] (HTTP protocol errors)
  /// - [FirebaseException] with network-related codes:
  ///   - `'network-request-failed'`
  ///   - `'unavailable'`
  ///
  /// Returns `false` for all other error types.
  bool _isNetworkError(Object error) {
    if (error is SocketException) {
      return true;
    }
    if (error is HttpException) {
      return true;
    }
    if (error is FirebaseException) {
      const networkErrorCodes = {
        'network-request-failed',
        'unavailable',
      };
      return networkErrorCodes.contains(error.code);
    }
    return false;
  }

  @override
  Future<Result<void>> createOrUpdateBackup(
    APIKeyConfig config,
    String passphrase, {
    DateTime? createdAt,
  }) async {
    try {
      // Validate user is authenticated
      if (_authService.currentUser == null) {
        return const Failure(BackupError(
          'User must be authenticated to create a backup',
          BackupErrorType.storageError,
        ));
      }

      // Step 1: Generate KDF metadata with fresh salt
      final kdfMetadata = await _keyDerivationService.generateMetadata();

      // Step 2: Derive encryption key from passphrase
      final encryptionKey = await _keyDerivationService.deriveKey(
        passphrase,
        kdfMetadata,
      );

      // Step 3: Serialize config to JSON bytes
      final configJson = jsonEncode(config.toJson());
      final configBytes = Uint8List.fromList(utf8.encode(configJson));

      // Step 4: Encrypt the config
      final encryptedData = await _encryptionService.encrypt(
        configBytes,
        encryptionKey,
      );

      // Step 5: Fetch existing blob to preserve createdAt timestamp (if not provided)
      final existingBlob = createdAt == null ? await _tryGetExistingBlob() : null;

      // Step 6: Create CloudBackupBlob
      final now = DateTime.now().toUtc();
      final blob = CloudBackupBlob(
        version: CloudBackupBlob.currentVersion,
        kdfMetadata: kdfMetadata,
        encryptedData: base64Encode(encryptedData),
        createdAt: createdAt ?? existingBlob?.createdAt ?? now,
        updatedAt: now,
      );

      // Step 7: Upload to Firebase Storage
      final blobJson = jsonEncode(blob.toJson());
      final ref = _storage.ref(_getBackupPath());
      await ref.putString(
        blobJson,
        metadata: SettableMetadata(contentType: 'application/json'),
      );

      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(BackupError(
        'Firebase Storage error: ${e.message}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    } on StateError catch (e) {
      return Failure(BackupError(
        e.message,
        BackupErrorType.storageError,
        originalError: e,
      ));
    } catch (e) {
      // Check for network-related errors
      if (_isNetworkError(e)) {
        return Failure(BackupError(
          'Network error during backup: ${e.toString()}',
          BackupErrorType.networkError,
          originalError: e,
        ));
      }
      return Failure(BackupError(
        'Failed to create backup: ${e.toString()}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    }
  }

  /// Decrypts a [CloudBackupBlob] using the provided passphrase.
  ///
  /// This helper extracts the decryption logic used by [restoreBackup]
  /// so it can be reused without re-fetching the blob.
  ///
  /// Returns [Success] with [APIKeyConfig] if decryption succeeds.
  /// Returns [Failure] with [BackupError] if:
  /// - Passphrase is incorrect ([BackupErrorType.wrongPassphrase])
  /// - Backup is corrupted ([BackupErrorType.corrupted])
  Future<Result<APIKeyConfig>> _decryptBlob(
    CloudBackupBlob blob,
    String passphrase,
  ) async {
    try {
      // Step 1: Derive decryption key from passphrase using stored KDF metadata
      final decryptionKey = await _keyDerivationService.deriveKey(
        passphrase,
        blob.kdfMetadata,
      );

      // Step 2: Decrypt the data
      final Uint8List decryptedBytes;
      try {
        final encryptedBytes = base64Decode(blob.encryptedData);
        decryptedBytes = await _encryptionService.decrypt(
          encryptedBytes,
          decryptionKey,
        );
      } on AuthenticationException catch (e) {
        // MAC verification failure indicates wrong passphrase
        return Failure(BackupError(
          'Incorrect passphrase',
          BackupErrorType.wrongPassphrase,
          originalError: e,
        ));
      } catch (e) {
        return Failure(BackupError(
          'Failed to decrypt backup: $e',
          BackupErrorType.corrupted,
          originalError: e,
        ));
      }

      // Step 3: Parse APIKeyConfig from decrypted JSON
      try {
        final configJson = utf8.decode(decryptedBytes);
        final configMap = jsonDecode(configJson) as Map<String, dynamic>;
        final config = APIKeyConfig.fromJson(configMap);
        return Success(config);
      } on FormatException catch (e) {
        return Failure(BackupError(
          'Backup is corrupted: invalid config format',
          BackupErrorType.corrupted,
          originalError: e,
        ));
      }
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(BackupError(
          'Network error during restore: ${e.toString()}',
          BackupErrorType.networkError,
          originalError: e,
        ));
      }
      return Failure(BackupError(
        'Failed to restore backup: ${e.toString()}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    }
  }

  @override
  Future<Result<APIKeyConfig>> restoreBackup(String passphrase) async {
    // Step 1: Fetch and parse the backup blob
    final blobResult = await _fetchAndParseBlob();
    if (blobResult.isFailure) {
      return Failure(blobResult.errorOrNull!);
    }
    final blob = blobResult.valueOrNull!;

    // Step 2: Decrypt using the helper
    return _decryptBlob(blob, passphrase);
  }

  @override
  Future<Result<void>> deleteBackup() async {
    try {
      // Validate user is authenticated
      if (_authService.currentUser == null) {
        return const Failure(BackupError(
          'User must be authenticated to delete a backup',
          BackupErrorType.storageError,
        ));
      }

      final ref = _storage.ref(_getBackupPath());
      await ref.delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      // If the file doesn't exist, consider it a success
      if (e.code == 'object-not-found') {
        return const Success(null);
      }
      return Failure(BackupError(
        'Firebase Storage error: ${e.message}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    } on StateError catch (e) {
      return Failure(BackupError(
        e.message,
        BackupErrorType.storageError,
        originalError: e,
      ));
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(BackupError(
          'Network error during deletion: ${e.toString()}',
          BackupErrorType.networkError,
          originalError: e,
        ));
      }
      return Failure(BackupError(
        'Failed to delete backup: ${e.toString()}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    }
  }

  @override
  Future<Result<bool>> backupExists() async {
    try {
      // Validate user is authenticated
      if (_authService.currentUser == null) {
        return const Failure(BackupError(
          'User must be authenticated to check backup existence',
          BackupErrorType.storageError,
        ));
      }

      final ref = _storage.ref(_getBackupPath());
      await ref.getMetadata();
      return const Success(true);
    } on FirebaseException catch (e) {
      // Only return Success(false) for object-not-found
      if (e.code == 'object-not-found') {
        return const Success(false);
      }
      // Propagate other Firebase errors (permission denied, etc.)
      return Failure(BackupError(
        'Firebase Storage error: ${e.message}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    } on StateError catch (e) {
      return Failure(BackupError(
        e.message,
        BackupErrorType.storageError,
        originalError: e,
      ));
    } catch (e) {
      // Check for network-related errors
      if (_isNetworkError(e)) {
        return Failure(BackupError(
          'Network error while checking backup existence: ${e.toString()}',
          BackupErrorType.networkError,
          originalError: e,
        ));
      }
      return Failure(BackupError(
        'Failed to check backup existence: ${e.toString()}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    }
  }

  @override
  Future<Result<void>> rotatePassphrase(
    String oldPassphrase,
    String newPassphrase,
  ) async {
    // This method implements a safe passphrase rotation using a temporary backup:
    // 1. Restore the existing backup with the old passphrase
    // 2. Capture the original createdAt timestamp before deletion
    // 3. Upload re-encrypted data to a temporary path
    // 4. Verify the temp backup can be decrypted with the new passphrase
    // 5. Perform atomic swap: delete old backup, then rename temp to final
    // 6. Clean up temp on any failure
    //
    // WARNING: Firebase Storage does not support atomic rename/move operations.
    // There is a brief window between deleting the old backup and the temp backup
    // being the only copy. If the process fails during this window, the user
    // should be able to restore from the temp backup manually or retry rotation.

    try {
      // Validate user is authenticated
      if (_authService.currentUser == null) {
        return const Failure(BackupError(
          'User must be authenticated to rotate passphrase',
          BackupErrorType.storageError,
        ));
      }

      // Step 1: Capture the original createdAt timestamp before any modifications
      final existingBlobResult = await _fetchAndParseBlob();
      if (existingBlobResult.isFailure) {
        return Failure(existingBlobResult.errorOrNull!);
      }
      final existingBlob = existingBlobResult.valueOrNull!;
      final originalCreatedAt = existingBlob.createdAt;

      // Step 2: Decrypt with old passphrase to get the config (no second fetch)
      final decryptResult = await _decryptBlob(existingBlob, oldPassphrase);
      if (decryptResult.isFailure) {
        return Failure(decryptResult.errorOrNull!);
      }
      final config = decryptResult.valueOrNull!;

      // Step 3: Create re-encrypted backup at temporary path
      final uploadTempResult = await _uploadToPath(
        config,
        newPassphrase,
        _getTempBackupPath(),
      );
      if (uploadTempResult.isFailure) {
        return Failure(uploadTempResult.errorOrNull!);
      }

      // Step 4: Verify the temp backup can be decrypted with new passphrase
      final verifyResult = await _verifyBackupAtPath(
        newPassphrase,
        _getTempBackupPath(),
      );
      if (verifyResult.isFailure) {
        // Clean up temp backup on verification failure
        await _deleteBackupAtPath(_getTempBackupPath());
        return Failure(BackupError(
          'Failed to verify re-encrypted backup: ${verifyResult.errorOrNull?.message}',
          BackupErrorType.corrupted,
          originalError: verifyResult.errorOrNull,
        ));
      }
      if (verifyResult.valueOrNull != true) {
        // Clean up temp backup if passphrase verification failed
        await _deleteBackupAtPath(_getTempBackupPath());
        return const Failure(BackupError(
          'Re-encrypted backup verification failed - passphrase mismatch',
          BackupErrorType.corrupted,
        ));
      }

      // Step 5: Atomic swap - delete old backup first, then copy temp to final
      // Note: Firebase Storage doesn't support atomic rename, so we:
      // a) Delete the original backup
      // b) Upload the temp content to the final path
      // c) Delete the temp backup
      //
      // If failure occurs between (a) and (b), the temp backup still exists
      // and can be manually recovered or rotation can be retried.

      // 5a: Delete the original backup
      final deleteOriginalResult = await deleteBackup();
      if (deleteOriginalResult.isFailure) {
        // Keep temp backup for recovery, but report the error
        return Failure(BackupError(
          'Failed to delete original backup during rotation. '
          'Temp backup preserved at temp path for manual recovery. '
          'Original error: ${deleteOriginalResult.errorOrNull?.message}',
          BackupErrorType.storageError,
          originalError: deleteOriginalResult.errorOrNull,
        ));
      }

      // 5b: Upload to final path, preserving the original createdAt timestamp
      final uploadFinalResult = await createOrUpdateBackup(
        config,
        newPassphrase,
        createdAt: originalCreatedAt,
      );
      if (uploadFinalResult.isFailure) {
        // CRITICAL: Original is deleted but final upload failed
        // Temp backup still exists - caller should be notified
        return Failure(BackupError(
          'CRITICAL: Original backup deleted but new backup upload failed. '
          'Your backup data is preserved at a temporary location. '
          'Please retry the passphrase rotation or contact support. '
          'Original error: ${uploadFinalResult.errorOrNull?.message}',
          BackupErrorType.storageError,
          originalError: uploadFinalResult.errorOrNull,
        ));
      }

      // Step 6: Clean up temp backup
      // Failure here is non-critical - the rotation succeeded
      await _deleteBackupAtPath(_getTempBackupPath());

      return const Success(null);
    } catch (e) {
      // Attempt to clean up temp backup on unexpected errors
      try {
        await _deleteBackupAtPath(_getTempBackupPath());
      } catch (_) {
        // Ignore cleanup errors
      }

      if (_isNetworkError(e)) {
        return Failure(BackupError(
          'Network error during passphrase rotation: ${e.toString()}',
          BackupErrorType.networkError,
          originalError: e,
        ));
      }
      return Failure(BackupError(
        'Failed to rotate passphrase: ${e.toString()}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    }
  }

  /// Uploads an encrypted backup to a specific path.
  ///
  /// This is an internal helper used by [rotatePassphrase] to upload
  /// to the temporary path.
  Future<Result<void>> _uploadToPath(
    APIKeyConfig config,
    String passphrase,
    String path,
  ) async {
    try {
      // Generate KDF metadata with fresh salt
      final kdfMetadata = await _keyDerivationService.generateMetadata();

      // Derive encryption key from passphrase
      final encryptionKey = await _keyDerivationService.deriveKey(
        passphrase,
        kdfMetadata,
      );

      // Serialize config to JSON bytes
      final configJson = jsonEncode(config.toJson());
      final configBytes = Uint8List.fromList(utf8.encode(configJson));

      // Encrypt the config
      final encryptedData = await _encryptionService.encrypt(
        configBytes,
        encryptionKey,
      );

      // Create CloudBackupBlob
      final now = DateTime.now().toUtc();
      final blob = CloudBackupBlob(
        version: CloudBackupBlob.currentVersion,
        kdfMetadata: kdfMetadata,
        encryptedData: base64Encode(encryptedData),
        createdAt: now,
        updatedAt: now,
      );

      // Upload to Firebase Storage at specified path
      final blobJson = jsonEncode(blob.toJson());
      final ref = _storage.ref(path);
      await ref.putString(
        blobJson,
        metadata: SettableMetadata(contentType: 'application/json'),
      );

      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(BackupError(
        'Firebase Storage error: ${e.message}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(BackupError(
          'Network error during upload: ${e.toString()}',
          BackupErrorType.networkError,
          originalError: e,
        ));
      }
      return Failure(BackupError(
        'Failed to upload backup: ${e.toString()}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    }
  }

  /// Verifies that a backup at the specified path can be decrypted.
  ///
  /// Returns [Success] with true if decryption succeeds.
  /// Returns [Success] with false if the passphrase is incorrect.
  /// Returns [Failure] if the backup doesn't exist or is corrupted.
  Future<Result<bool>> _verifyBackupAtPath(
    String passphrase,
    String path,
  ) async {
    try {
      // Download backup from specified path
      final ref = _storage.ref(path);
      final data = await ref.getData();
      if (data == null) {
        return const Failure(BackupError(
          'Backup not found at specified path',
          BackupErrorType.notFound,
        ));
      }

      // Parse CloudBackupBlob
      final CloudBackupBlob blob;
      try {
        final blobJson = utf8.decode(data);
        final blobMap = jsonDecode(blobJson) as Map<String, dynamic>;
        blob = CloudBackupBlob.fromJson(blobMap);
      } on FormatException catch (e) {
        return Failure(BackupError(
          'Backup is corrupted: ${e.message}',
          BackupErrorType.corrupted,
          originalError: e,
        ));
      }

      // Derive decryption key and attempt decryption
      final decryptionKey = await _keyDerivationService.deriveKey(
        passphrase,
        blob.kdfMetadata,
      );

      try {
        final encryptedBytes = base64Decode(blob.encryptedData);
        await _encryptionService.decrypt(encryptedBytes, decryptionKey);
        return const Success(true);
      } catch (_) {
        // Decryption failed - wrong passphrase
        return const Success(false);
      }
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return const Failure(BackupError(
          'Backup not found',
          BackupErrorType.notFound,
        ));
      }
      return Failure(BackupError(
        'Firebase Storage error: ${e.message}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(BackupError(
          'Network error: ${e.toString()}',
          BackupErrorType.networkError,
          originalError: e,
        ));
      }
      return Failure(BackupError(
        'Failed to verify backup: ${e.toString()}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    }
  }

  /// Deletes a backup at the specified path.
  ///
  /// Returns [Success] if deletion was successful or backup didn't exist.
  /// Returns [Failure] if deletion fails.
  Future<Result<void>> _deleteBackupAtPath(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      // If the file doesn't exist, consider it a success
      if (e.code == 'object-not-found') {
        return const Success(null);
      }
      return Failure(BackupError(
        'Firebase Storage error: ${e.message}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(BackupError(
          'Network error during deletion: ${e.toString()}',
          BackupErrorType.networkError,
          originalError: e,
        ));
      }
      return Failure(BackupError(
        'Failed to delete backup: ${e.toString()}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    }
  }

  /// Attempts to fetch and parse the existing backup blob without decryption.
  ///
  /// Returns the [CloudBackupBlob] if it exists and can be parsed.
  /// Returns null if:
  /// - No backup exists
  /// - User is not authenticated
  /// - Backup cannot be parsed (corrupted)
  /// - Any other error occurs
  ///
  /// This method is used to preserve the [createdAt] timestamp when updating
  /// an existing backup.
  Future<CloudBackupBlob?> _tryGetExistingBlob() async {
    try {
      // Check if user is authenticated
      if (_authService.currentUser == null) {
        return null;
      }

      // Download backup from Firebase Storage
      final ref = _storage.ref(_getBackupPath());
      final data = await ref.getData();
      if (data == null) {
        return null;
      }

      // Parse CloudBackupBlob
      final blobJson = utf8.decode(data);
      final blobMap = jsonDecode(blobJson) as Map<String, dynamic>;
      return CloudBackupBlob.fromJson(blobMap);
    } catch (_) {
      // Any error means we can't get the existing blob
      // This is non-fatal - we'll just use current time for createdAt
      return null;
    }
  }

  /// Fetches and parses the backup blob from Firebase Storage.
  ///
  /// This helper encapsulates the common download-and-parse logic used by
  /// [restoreBackup] and [verifyPassphrase].
  ///
  /// Returns [Success] with [CloudBackupBlob] if the backup exists and can be parsed.
  /// Returns [Failure] with [BackupError] if:
  /// - User is not authenticated ([BackupErrorType.storageError])
  /// - Backup doesn't exist ([BackupErrorType.notFound])
  /// - Backup is corrupted ([BackupErrorType.corrupted])
  /// - Network error occurs ([BackupErrorType.networkError])
  Future<Result<CloudBackupBlob>> _fetchAndParseBlob() async {
    try {
      // Validate user is authenticated
      if (_authService.currentUser == null) {
        return const Failure(BackupError(
          'User must be authenticated to access backup',
          BackupErrorType.storageError,
        ));
      }

      // Download backup from Firebase Storage
      final ref = _storage.ref(_getBackupPath());
      final data = await ref.getData();
      if (data == null) {
        return const Failure(BackupError(
          'Backup not found',
          BackupErrorType.notFound,
        ));
      }

      // Parse CloudBackupBlob
      try {
        final blobJson = utf8.decode(data);
        final blobMap = jsonDecode(blobJson) as Map<String, dynamic>;
        final blob = CloudBackupBlob.fromJson(blobMap);
        return Success(blob);
      } on FormatException catch (e) {
        return Failure(BackupError(
          'Backup is corrupted: ${e.message}',
          BackupErrorType.corrupted,
          originalError: e,
        ));
      }
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return const Failure(BackupError(
          'Backup not found',
          BackupErrorType.notFound,
        ));
      }
      return Failure(BackupError(
        'Firebase Storage error: ${e.message}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    } on StateError catch (e) {
      return Failure(BackupError(
        e.message,
        BackupErrorType.storageError,
        originalError: e,
      ));
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(BackupError(
          'Network error: ${e.toString()}',
          BackupErrorType.networkError,
          originalError: e,
        ));
      }
      return Failure(BackupError(
        'Failed to fetch backup: ${e.toString()}',
        BackupErrorType.storageError,
        originalError: e,
      ));
    }
  }

  @override
  Future<Result<bool>> verifyPassphrase(String passphrase) async {
    // Delegate to _verifyBackupAtPath with the default backup path.
    // This eliminates duplicate blob fetching and decryption/error-mapping logic.
    return _verifyBackupAtPath(passphrase, _getBackupPath());
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

/// Provider for [FirebaseStorage].
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Provider for [KeyDerivationService].
final keyDerivationServiceProvider = Provider<KeyDerivationService>((ref) {
  return KeyDerivationServiceImpl();
});

/// Provider for [EncryptionService].
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return AESGCMEncryptionService();
});

/// Provider for [CloudBackupService].
///
/// Creates a [CloudBackupServiceImpl] instance with injected dependencies.
final cloudBackupServiceProvider = Provider<CloudBackupService>((ref) {
  final storage = ref.watch(firebaseStorageProvider);
  final authService = ref.watch(authServiceProvider);
  final keyDerivationService = ref.watch(keyDerivationServiceProvider);
  final encryptionService = ref.watch(encryptionServiceProvider);

  return CloudBackupServiceImpl(
    storage: storage,
    authService: authService,
    keyDerivationService: keyDerivationService,
    encryptionService: encryptionService,
  );
});
