import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import 'age_verification_service.dart';
import 'models/user_profile.dart';

/// Provider for the [AuthService] instance.
///
/// This provider creates and manages a singleton instance of
/// [AuthServiceImpl] that can be used throughout the app
/// to handle authentication operations.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthServiceImpl();
});

/// Provider for the [AgeVerificationService] instance.
///
/// This provider creates and manages a singleton instance of
/// [AgeVerificationServiceImpl] that can be used throughout the app
/// to handle age verification operations.
final ageVerificationServiceProvider =
    Provider<AgeVerificationService>((ref) {
  return AgeVerificationServiceImpl();
});

/// Provider that checks if a user is currently signed in.
///
/// This is a [FutureProvider] that asynchronously checks the authentication
/// status. It's useful for determining the initial route during app startup.
final isSignedInProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(authServiceProvider);
  return service.isSignedIn();
});

/// Provider for the current user's profile.
///
/// This is a [FutureProvider] that retrieves the authenticated user's
/// profile from Firestore. Returns null if the user is not signed in.
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final service = ref.read(authServiceProvider);
  return service.getUserProfile();
});

/// Provider for the current user's age verification status.
///
/// This is a [FutureProvider] that checks if the current user has
/// been verified as 18+ years old.
final is18PlusVerifiedProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(authServiceProvider);
  final profile = await service.getUserProfile();
  return profile?.is18PlusVerified ?? false;
});

/// StateNotifier for managing authentication state.
///
/// This [StateNotifier] provides reactive state management for
/// authentication, allowing UI components to respond to auth state changes.
class AuthStateNotifier extends StateNotifier<AuthState> {
  /// Creates an [AuthStateNotifier] with the given services.
  AuthStateNotifier(this._authService, this._ageVerificationService)
      : super(const AuthState.initial());

  final AuthService _authService;
  final AgeVerificationService _ageVerificationService;

  /// Initializes the auth state by checking if a user is signed in.
  Future<void> initialize() async {
    try {
      final signedIn = await _authService.isSignedIn();
      if (signedIn) {
        final profile = await _authService.getUserProfile();
        if (profile != null) {
          state = AuthState.authenticated(profile);
        } else {
          state = const AuthState.unauthenticated();
        }
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Signs in a user with email and password.
  Future<void> signInWithEmail(String email, String password) async {
    state = const AuthState.loading();
    try {
      final profile = await _authService.signInWithEmail(email, password);
      state = AuthState.authenticated(profile);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Signs up a new user with email, password, and date of birth.
  Future<void> signUpWithEmail(
    String email,
    String password,
    DateTime dateOfBirth,
  ) async {
    state = const AuthState.loading();
    try {
      final profile = await _authService.signUpWithEmail(
        email,
        password,
        dateOfBirth,
      );
      state = AuthState.authenticated(profile);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _authService.signOut();
  /// Updates the user's face detection consent.
  Future<void> updateFaceDetectionConsent(bool granted) async {
    try {
      await _authService.updateFaceDetectionConsent(granted);
      final profile = await _authService.getUserProfile();
      if (profile != null) {
        state = AuthState.authenticated(
          profile.copyWith(faceDetectionConsentGranted: granted),
        );
      }
    } catch (e) {
      // Log error but preserve auth state
      debugPrint('Failed to update face detection consent: $e');
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Updates the user's biometric consent.
  Future<void> updateBiometricConsent(bool granted) async {
    try {
      await _authService.updateBiometricConsent(granted);
      final profile = await _authService.getUserProfile();
      if (profile != null) {
        state = AuthState.authenticated(
          profile.copyWith(biometricConsentGranted: granted),
        );
      }
    } catch (e) {
      // Log error but preserve auth state
      debugPrint('Failed to update biometric consent: $e');
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

/// Represents the current state of authentication.
///
/// This immutable class holds information about the user's
/// authentication status and any error states.
class AuthState {
  /// Creates an [AuthState] instance.
  const AuthState._({
    this.status = AuthStatus.unauthenticated,
    this.profile,
    this.errorMessage,
  });

  /// Creates an initial (unauthenticated) state.
  const AuthState.initial() : this._(status: AuthStatus.initial);

  /// Creates an unauthenticated state (user not signed in).
  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);

  /// Creates an authenticated state with the given profile.
  const AuthState.authenticated(UserProfile profile)
      : this._(status: AuthStatus.authenticated, profile: profile);

  /// Creates an error state with the given message.
  const AuthState.error(String errorMessage)
      : this._(status: AuthStatus.error, errorMessage: errorMessage);

  /// Creates a loading state.
  const AuthState.loading() : this._(status: AuthStatus.loading);

  /// The current authentication status.
  final AuthStatus status;

  /// The user's profile if authenticated.
  final UserProfile? profile;

  /// An error message if an error occurred.
  final String? errorMessage;

  /// Whether the user is currently signed in.
  bool get isSignedIn => status == AuthStatus.authenticated;

  /// Whether the user is 18+ verified.
  bool get is18PlusVerified => profile?.is18PlusVerified ?? false;

  /// Creates a copy of this state with the given fields replaced.
  AuthState copyWith({
    AuthStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return AuthState._(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.profile == profile &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, profile, errorMessage);

  @override
  String toString() {
    return 'AuthState(status: $status, profile: $profile, errorMessage: $errorMessage)';
  }
}

/// Represents the different states of authentication.
enum AuthStatus {
  /// Initial state before any authentication check.
  initial,

  /// User is not signed in.
  unauthenticated,

  /// User is signed in and authenticated.
  authenticated,

  /// An error occurred during authentication.
  error,

  /// An operation is in progress.
  loading,
}

/// Provider for the [AuthStateNotifier].
///
/// This provider creates a [StateNotifierProvider] that manages the
/// authentication state. Use this provider in UI components to
/// react to authentication state changes.
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  final ageVerificationService = ref.read(ageVerificationServiceProvider);
  return AuthStateNotifier(authService, ageVerificationService);
});
