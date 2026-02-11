/// Custom exception for authentication-related errors.
class AuthError implements Exception {
  /// Creates an [AuthError] with the given message and optional code.
  const AuthError(this.message, [this.code]);

  /// A human-readable error message.
  final String message;

  /// An optional error code for programmatic handling.
  final String? code;

  @override
  String toString() {
    if (code != null) {
      return 'AuthError($code): $message';
    }
    return 'AuthError: $message';
  }
}

/// Error codes for authentication operations.
class AuthErrorCode {
  /// The email address is already in use by another account.
  static const String emailAlreadyInUse = 'email-already-in-use';

  /// The provided email is invalid.
  static const String invalidEmail = 'invalid-email';

  /// The password is too weak or doesn't meet requirements.
  static const String weakPassword = 'weak-password';

  /// The user account has been disabled by an administrator.
  static const String userDisabled = 'user-disabled';

  /// The user was not found.
  static const String userNotFound = 'user-not-found';

  /// The password is invalid.
  static const String wrongPassword = 'wrong-password';

  /// The operation is not allowed.
  static const String operationNotAllowed = 'operation-not-allowed';

  /// The user is not 18+ years old.
  static const String underAge = 'under-age';

  /// The user is currently in a cooldown period.
  static const String cooldownActive = 'cooldown-active';

  /// The user's account is pending age verification.
  static const String pendingVerification = 'pending-verification';

  /// A general error occurred during authentication.
  static const String generalError = 'general-error';

  /// The provided input is invalid.
  static const String invalidInput = 'invalid-input';

  /// Failed to initiate third-party verification.
  static const String verificationInitiationFailed = 'third-party-initiation-failed';

  /// The requested feature is not implemented.
  static const String notImplemented = 'not-implemented';
}
