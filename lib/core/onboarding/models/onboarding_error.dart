/// Represents an error that occurred during onboarding operations.
///
/// This class provides a type-safe error representation for the onboarding
/// flow, wrapping any underlying exceptions with context about the operation
/// that failed.
///
/// Example usage:
/// ```dart
/// try {
///   await controller.markOnboardingComplete();
/// } catch (e, stack) {
///   state = OnboardingState.error(
///     OnboardingError(
///       'Failed to save onboarding progress',
///       operation: OnboardingOperation.markComplete,
///       originalError: e,
///       originalStackTrace: stack,
///     ),
///     currentStep: OnboardingStep.apiKeyInput,
///   );
/// }
/// ```
class OnboardingError implements Exception {
  /// Creates an [OnboardingError] with the given message.
  ///
  /// [message] is a human-readable description of the error.
  /// [operation] indicates which onboarding operation failed.
  /// [originalError] is the underlying exception that caused this error.
  /// [originalStackTrace] is the stack trace captured when the error occurred.
  const OnboardingError(
    this.message, {
    this.operation,
    this.originalError,
    this.originalStackTrace,
  });

  /// A human-readable description of the error.
  final String message;

  /// The onboarding operation that failed, if known.
  final OnboardingOperation? operation;

  /// The original error that caused this onboarding error.
  ///
  /// This is useful for debugging and logging while keeping the
  /// user-facing error message clean.
  final Object? originalError;

  /// The stack trace captured when the original error occurred.
  ///
  /// This preserves full diagnostic information for debugging and logging.
  final StackTrace? originalStackTrace;

  @override
  String toString() => operation != null
      ? 'OnboardingError(${operation!.name}): $message'
      : 'OnboardingError: $message';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingError &&
        other.message == message &&
        other.operation == operation &&
        other.originalError == originalError;
  }

  @override
  int get hashCode => Object.hash(message, operation, originalError);
}

/// Enumeration of onboarding operations that can fail.
enum OnboardingOperation {
  /// Checking if onboarding is complete.
  checkComplete,

  /// Marking onboarding as complete.
  markComplete,

  /// Resetting onboarding state.
  reset,
}
