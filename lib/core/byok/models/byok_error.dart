import 'validation_result.dart';

/// Errors that can occur during BYOK operations.
///
/// This is a sealed class hierarchy representing all possible error types
/// that can occur during API key management operations.
sealed class BYOKError {
  /// Human-readable error message.
  final String message;

  /// Optional underlying error that caused this error.
  final Object? originalError;

  const BYOKError(this.message, {this.originalError});
}

/// API key validation failed.
///
/// Contains the validation result with specific failure information.
class ValidationError extends BYOKError {
  /// The validation result containing failure details.
  final ValidationResult validationResult;

  const ValidationError(
    super.message,
    this.validationResult, {
    super.originalError,
  });

  @override
  String toString() =>
      'ValidationError($message, $validationResult${originalError != null ? ', originalError: $originalError' : ''})';
}

/// No API key is stored.
///
/// Returned when attempting to retrieve or delete a key that doesn't exist.
class NotFoundError extends BYOKError {
  const NotFoundError({super.originalError}) : super('No API key is stored');

  @override
  String toString() =>
      'NotFoundError($message${originalError != null ? ', originalError: $originalError' : ''})';
}

/// Secure storage operation failed.
///
/// Returned when reading from or writing to secure storage fails.
class StorageError extends BYOKError {
  const StorageError(super.message, {super.originalError});

  @override
  String toString() =>
      'StorageError($message${originalError != null ? ', originalError: $originalError' : ''})';
}

/// Cloud backup operation failed.
///
/// Contains the specific type of backup failure.
class BackupError extends BYOKError {
  /// The type of backup failure.
  final BackupErrorType type;

  const BackupError(super.message, this.type, {super.originalError});

  @override
  String toString() =>
      'BackupError($message, type: $type${originalError != null ? ', originalError: $originalError' : ''})';
}

/// Types of backup errors.
enum BackupErrorType {
  /// Backup does not exist.
  notFound,

  /// Passphrase is incorrect.
  wrongPassphrase,

  /// Backup is corrupted.
  corrupted,

  /// Network error during backup operation.
  networkError,

  /// Cloud storage service error.
  storageError,
}

/// Encryption or decryption failed.
///
/// Returned when cryptographic operations fail.
class CryptoError extends BYOKError {
  const CryptoError(super.message, {super.originalError});

  @override
  String toString() =>
      'CryptoError($message${originalError != null ? ', originalError: $originalError' : ''})';
}
