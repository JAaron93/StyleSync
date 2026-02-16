import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/utils/network_error_checker_stub.dart'
    if (dart.library.io) '../../core/utils/network_error_checker_io.dart';
import 'models/onboarding_error.dart';
import 'models/onboarding_persistence_exception.dart';

/// Default generic error message when no user-friendly message is available.
const String genericErrorMessage = 'Something went wrong. Please try again.';

/// Maximum allowed length for user-facing error messages.
const int maxMessageLength = 200;

/// Patterns that indicate a message contains technical details.
///
/// Matches specific technical patterns while avoiding false positives:
/// - "Exception:" or "Error:" with colon (typical exception prefixes)
/// - "StackTrace" as compound word
/// - Stack frame patterns like "#0 " or "at file.dart:123"
/// - Package references like "(package:...)"
/// - JSON-like braces and brackets
/// - Hex memory addresses (0x...)
/// - Standalone "null" or "undefined"
final RegExp technicalPatterns = RegExp(
  r'('
  r'Exception:|Error:' // Exception/Error followed by colon
  r'|StackTrace' // Compound word StackTrace
  r'|\bnull\b|\bundefined\b' // Standalone null/undefined
  r'|\{|\}|\[|\]' // JSON-like braces
  r'|0x[0-9a-fA-F]+' // Hex addresses
  r'|#\d+\s+' // Numbered stack frames (#0, #1, etc.)
  r'|\bat\s+\S+\.dart:\d+' // Dart stack trace: "at file.dart:123"
  r'|\(package:[^)]+\)' // Package references: "(package:...)"
  r')',
  caseSensitive: false,
);

/// Checks if the given message is safe and user-friendly for display.
///
/// Returns `true` if the message is non-empty, within length limits,
/// and doesn't contain technical patterns.
bool isUserFriendlyMessage(String? message) {
  if (message == null || message.trim().isEmpty) {
    return false;
  }
  if (message.length > maxMessageLength) {
    return false;
  }
  if (technicalPatterns.hasMatch(message)) {
    return false;
  }
  return true;
}

/// Checks if the given error is a network-related error.
///
/// Returns `true` if the error is a [TimeoutException], [SocketException],
/// or [HttpException].
bool isNetworkError(Object? error) {
  return error is TimeoutException ||
      isSocketException(error) ||
      isHttpException(error);
}

/// Formats an [OnboardingError] into a user-friendly message.
///
/// Maps known error types to readable strings and falls back to the
/// error's message or a generic message for unknown errors.
/// The raw error is logged internally for debugging purposes.
///
/// This ensures technical details like stack traces or exception types
/// are never exposed to users.
String formatOnboardingError(OnboardingError? error) {
  if (error == null) {
    return genericErrorMessage;
  }

  // Log error type for debugging (avoid logging potentially sensitive error details)
  debugPrint('Onboarding error: ${error.runtimeType} (original type: ${error.originalError?.runtimeType})');

  final originalError = error.originalError;

  // Map known original error types to user-friendly messages
  if (originalError is OnboardingPersistenceException) {
    // Storage-related errors
    return 'Unable to save your progress. Please check your device storage and try again.';
  }

  if (originalError is FormatException) {
    return 'Invalid data format. Please try again.';
  }

  if (originalError is StateError) {
    return 'The app encountered an issue. Please restart and try again.';
  }

  // Handle network-related errors
  if (isNetworkError(originalError)) {
    return 'Network error. Please check your connection and try again.';
  }

  // Use the OnboardingError's message as fallback if it's user-friendly
  if (isUserFriendlyMessage(error.message)) {
    return error.message;
  }

  return genericErrorMessage;
}
