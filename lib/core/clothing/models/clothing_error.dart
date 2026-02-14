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
  /// The ID of the item that was not found, if known.
  final String? itemId;

  const ClothingItemNotFoundError([this.itemId])
      : super(itemId == null
            ? 'Clothing item not found'
            : 'Clothing item not found: $itemId');

  @override
  String toString() => 'ClothingItemNotFoundError($message, itemId: $itemId)';
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
  factory StorageQuota.fromJson(Map<String, dynamic> json) {
    final itemCount = _safeToInt(json['itemCount'], 'itemCount');
    final maxItems = _safeToInt(json['maxItems'], 'maxItems');
    final bytesUsed = _safeToInt(json['bytesUsed'], 'bytesUsed');
    final maxBytes = _safeToInt(json['maxBytes'], 'maxBytes');

    return StorageQuota(
      itemCount: itemCount,
      maxItems: maxItems,
      bytesUsed: bytesUsed,
      maxBytes: maxBytes,
    );
  }

  /// Safely converts a value to int, throwing a clear FormatException if invalid.
  static int _safeToInt(dynamic value, String fieldName) {
    if (value == null) {
      throw FormatException(
        'StorageQuota: field "$fieldName" is null',
      );
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      // Check for fractional numbers that would lose precision
      if (value % 1 != 0) {
        // For storage quota, we want to be strict about precision
        // Throw an error to prevent silent truncation of quota values
        throw FormatException(
          'StorageQuota: field "$fieldName" has fractional value $value which would lose precision when converted to int. '
          'Storage quota values must be whole numbers.',
        );
      }
      return value.toInt();
    }

    if (value is String) {
      try {
        return int.parse(value);
      } on FormatException catch (e) {
        throw FormatException(
          'StorageQuota: field "$fieldName" is not a valid integer: $e',
        );
      }
    }

    throw FormatException(
      'StorageQuota: field "$fieldName" has invalid type ${value.runtimeType}',
    );
  }

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
