/// Result of an API key validation operation.
///
/// This is a sealed class hierarchy that represents either a successful
/// validation or a failure with specific error information.
sealed class ValidationResult {
  const ValidationResult();
}

/// Validation succeeded.
///
/// Contains optional metadata from the validation, such as available models
/// returned from the Vertex AI API.
class ValidationSuccess extends ValidationResult {
  /// Optional metadata from the validation (e.g., available models).
  final Map<String, dynamic>? metadata;

  const ValidationSuccess({this.metadata});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationSuccess &&
          runtimeType == other.runtimeType &&
          _mapEquals(metadata, other.metadata);

  @override
  int get hashCode => _deepHashCode(metadata);

  @override
  String toString() => 'ValidationSuccess(metadata: $metadata)';

  /// Performs deep equality comparison of two maps.
  ///
  /// Handles nested Maps and Lists recursively, comparing primitives by ==.
  /// Accepts any Map type to support nested maps with non-String keys.
  static bool _mapEquals(Map? a, Map? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (!_deepEquals(a[key], b[key])) return false;
    }
    return true;
  }

  /// Performs deep equality comparison of two values.
  ///
  /// Recursively compares Maps and Lists, and uses == for primitives.
  static bool _deepEquals(dynamic a, dynamic b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;

    // Handle Map comparison (any key type)
    if (a is Map && b is Map) {
      return _mapEquals(a, b);
    }

    // Handle List comparison
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    }

    // Primitive comparison
    return a == b;
  }

  /// Computes a content-based hash code consistent with [_mapEquals].
  ///
  /// Recursively hashes Maps and Lists, and uses hashCode for primitives.
  /// This ensures that two instances with equal metadata per [_mapEquals]
  /// produce the same hash code.
  static int _deepHashCode(dynamic value) {
    if (value == null) return 0;

    // Handle Map hashing (any key type)
    if (value is Map) {
      var hash = 1;
      // Sort keys by hashCode to ensure consistent ordering for any key type
      final sortedKeys = value.keys.toList()..sort((a, b) => a.hashCode.compareTo(b.hashCode));
      for (final key in sortedKeys) {
        // Use rolling hash with multiplication to reduce collisions
        hash = hash * 31 + key.hashCode;
        hash = hash * 31 + _deepHashCode(value[key]);
      }
      return hash;
    }

    // Handle List hashing
    if (value is List) {
      var hash = 1;
      for (var i = 0; i < value.length; i++) {
        // Use rolling hash with multiplication for position-sensitivity
        // This ensures [a, b] produces a different hash than [b, a]
        final elementHash = _deepHashCode(value[i]);
        hash = hash * 31 + elementHash;
      }
      return hash;
    }

    // Primitive hashing
    return value.hashCode;
  }
}

/// Validation failed.
///
/// Contains detailed information about why the validation failed,
/// including the failure type, a human-readable message, and optional
/// error code and underlying error.
class ValidationFailure extends ValidationResult {
  /// The type of validation failure.
  final ValidationFailureType type;

  /// Human-readable error message.
  final String message;

  /// Optional error code from the API.
  final String? errorCode;

  /// Optional underlying error.
  final Object? originalError;

  const ValidationFailure({
    required this.type,
    required this.message,
    this.errorCode,
    this.originalError,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationFailure &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message &&
          errorCode == other.errorCode;

  @override
  int get hashCode => type.hashCode ^ message.hashCode ^ errorCode.hashCode;

  @override
  String toString() => 'ValidationFailure('
      'type: $type, '
      'message: $message, '
      'errorCode: $errorCode)';
}

/// Types of validation failures.
///
/// Each type corresponds to a specific error condition that can occur
/// during API key validation.
enum ValidationFailureType {
  /// API key format is invalid (e.g., doesn't start with 'AIza').
  invalidFormat,

  /// API key is malformed (wrong length, invalid characters).
  malformedKey,

  /// API key is not authorized (invalid or revoked).
  unauthorized,

  /// Project ID is invalid or inaccessible.
  invalidProject,

  /// Vertex AI API is not enabled for the project.
  apiNotEnabled,

  /// Network error during validation.
  networkError,

  /// Rate limit exceeded during validation.
  rateLimited,

  /// Unknown or unexpected error.
  unknown,
}
