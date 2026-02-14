/// A minimal, platform-agnostic representation of an authenticated user.
///
/// This abstraction decouples the application layer from Firebase Auth,
/// allowing callers to access basic user information without depending
/// on firebase_auth directly.
class AuthUser {
  /// Creates an [AuthUser] with the given properties.
  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
  });

  /// The unique identifier for this user.
  final String id;

  /// The user's email address, or null if not available.
  final String? email;

  /// The user's display name, or null if not available.
  final String? displayName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName;
  }

  @override
  int get hashCode => Object.hash(id, email, displayName);

  @override
  String toString() {
    return 'AuthUser(id: $id, email: $email, displayName: $displayName)';
  }
}
