/// Exception thrown when onboarding persistence operations fail.
///
/// This exception is thrown by [OnboardingController] implementations
/// when reading from or writing to persistent storage fails.
///
/// Common causes:
/// - Storage backend unavailable
/// - Write operation returned false (storage full, permissions, etc.)
/// - Corrupted data in storage
class OnboardingPersistenceException implements Exception {
  /// Creates an [OnboardingPersistenceException] with the given message.
  const OnboardingPersistenceException(this.message, {this.operation});

  /// A human-readable description of the error.
  final String message;

  /// The operation that failed, if known.
  ///
  /// Typical values: 'markOnboardingComplete', 'isOnboardingComplete', 'resetOnboarding'.
  final String? operation;

  @override
  String toString() {
    if (operation != null) {
      return 'OnboardingPersistenceException($operation): $message';
    }
    return 'OnboardingPersistenceException: $message';
  }
}
