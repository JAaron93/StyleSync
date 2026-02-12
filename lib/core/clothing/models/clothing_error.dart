/// Errors that can occur during clothing operations.
sealed class ClothingError {
  /// Human-readable error message.
  final String message;

  /// Optional underlying error that caused this error.
  final Object? originalError;

  const ClothingError(this.message, {this.originalError});
}

/// Storage quota has been exceeded.
///
/// Returned when attempting to upload more items than allowed.
class StorageQuotaExceededError extends ClothingError {
  /// Current usage statistics.
  final StorageQuota quota;

  const StorageQuotaExceededError(this.quota)
      : super('Storage quota exceeded');

  @override
  String toString() => 'StorageQuotaExceededError($message, quota: $quota)';
}

/// No clothing item found.
///
/// Returned when attempting to retrieve or delete an item that doesn't exist.
class ClothingItemNotFoundError extends ClothingError {
  const ClothingItemNotFoundError() : super('Clothing item not found');

  @override
  String toString() => 'ClothingItemNotFoundError($message)';
}

/// Firebase operation failed.
///
/// Returned when Firestore or Firebase Storage operations fail.
class FirebaseError extends ClothingError {
  const FirebaseError(super.message, {super.originalError});

  @override
  String toString() => 'FirebaseError($message)';
}

/// Network error occurred.
///
/// Returned when network connectivity is lost or requests fail.
class NetworkError extends ClothingError {
  const NetworkError(super.message, {super.originalError});

  @override
  String toString() => 'NetworkError($message)';
}

/// Processing error occurred.
///
/// Returned when background removal or tagging fails.
class ProcessingError extends ClothingError {
  const ProcessingError(super.message, {super.originalError});

  @override
  String toString() => 'ProcessingError($message)';
}

/// Validation error occurred.
///
/// Returned when input validation fails.
class ClothingValidationError extends ClothingError {
  const ClothingValidationError(super.message, {super.originalError});

  @override
  String toString() => 'ClothingValidationError($message)';
}

/// Storage quota information.
class StorageQuota {
  /// Current number of items stored.
  final int itemCount;

  /// Maximum number of items allowed (500).
  final int maxItems;

  /// Current storage usage in bytes.
  final int bytesUsed;

  /// Maximum storage allowed in bytes (2GB = 2 * 1024 * 1024 * 1024).
  final int maxBytes;

  /// Whether the quota has been exceeded.
  final bool isExceeded;

  const StorageQuota({
    required this.itemCount,
    required this.maxItems,
    required this.bytesUsed,
    required this.maxBytes,
  }) : isExceeded = itemCount >= maxItems || bytesUsed >= maxBytes;

  /// Creates a copy of this quota with the given fields replaced.
  StorageQuota copyWith({
    int? itemCount,
    int? maxItems,
    int? bytesUsed,
    int? maxBytes,
  }) =>
      StorageQuota(
        itemCount: itemCount ?? this.itemCount,
        maxItems: maxItems ?? this.maxItems,
        bytesUsed: bytesUsed ?? this.bytesUsed,
        maxBytes: maxBytes ?? this.maxBytes,
      );

  /// Serializes this quota to a JSON map.
  Map<String, dynamic> toJson() => {
        'itemCount': itemCount,
        'maxItems': maxItems,
        'bytesUsed': bytesUsed,
        'maxBytes': maxBytes,
        'isExceeded': isExceeded,
      };

  /// Creates a [StorageQuota] from a JSON map.
  factory StorageQuota.fromJson(Map<String, dynamic> json) => StorageQuota(
        itemCount: json['itemCount'] as int,
        maxItems: json['maxItems'] as int,
        bytesUsed: json['bytesUsed'] as int,
        maxBytes: json['maxBytes'] as int,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageQuota &&
          runtimeType == other.runtimeType &&
          itemCount == other.itemCount &&
          maxItems == other.maxItems &&
          bytesUsed == other.bytesUsed &&
          maxBytes == other.maxBytes &&
          isExceeded == other.isExceeded;

  @override
  int get hashCode => Object.hash(
        itemCount,
        maxItems,
        bytesUsed,
        maxBytes,
        isExceeded,
      );

  @override
  String toString() => 'StorageQuota(itemCount: $itemCount/$maxItems, '
      'bytesUsed: $bytesUsed/$maxBytes, isExceeded: $isExceeded)';
}
