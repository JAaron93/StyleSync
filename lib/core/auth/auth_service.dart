import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/user_profile.dart';
import 'models/auth_error.dart';

/// Abstract interface for authentication services.
///
/// This service handles user authentication including:
/// - Email/password sign-up and sign-in
/// - Social authentication (Google, Apple)
/// - 18+ age verification
/// - User profile management
abstract class AuthService {
  /// The currently authenticated user, or null if not signed in.
  User? get currentUser;

  /// Checks if a user is currently signed in.
  Future<bool> isSignedIn();

  /// Signs in a user with email and password.
  ///
  /// Throws [AuthError] if authentication fails.
  Future<UserProfile> signInWithEmail(String email, String password);

  /// Signs up a new user with email and password.
  ///
  /// The [dateOfBirth] parameter is required for 18+ age verification.
  /// Throws [AuthError] if sign-up fails or user is under 18.
  Future<UserProfile> signUpWithEmail(
    String email,
    String password,
    DateTime dateOfBirth,
  );

  /// Signs in with Google credentials.
  ///
  /// Throws [AuthError] if authentication fails.
  Future<UserProfile> signInWithGoogle();

  /// Signs in with Apple credentials.
  ///
  /// Throws [AuthError] if authentication fails.
  Future<UserProfile> signInWithApple();

  /// Signs out the current user.
  Future<void> signOut();

  /// Gets the current user's profile from Firestore.
  ///
  /// Returns null if the user doesn't have a profile.
  Future<UserProfile?> getUserProfile();

  /// Creates or updates the user's profile in Firestore.
  Future<void> upsertUserProfile(UserProfile profile);

  /// Verifies the user is 18+ years old.
  ///
  /// Throws [AuthError] if the user is under 18.
  Future<void> verify18Plus(DateTime dateOfBirth);

  /// Updates the user's consent status for face detection.
  Future<void> updateFaceDetectionConsent(bool granted);

  /// Updates the user's consent status for biometric processing.
  Future<void> updateBiometricConsent(bool granted);
}

/// Implementation of [AuthService] using Firebase Auth and Firestore.
class AuthServiceImpl implements AuthService {
  /// Creates an [AuthServiceImpl] instance.
  AuthServiceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firebaseFirestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firebaseFirestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<bool> isSignedIn() async {
    return _auth.currentUser != null;
  }

  @override
  Future<UserProfile> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userProfile = await _getUserProfileFromUser(credential.user!);
      return userProfile;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      throw AuthError('An unexpected error occurred during sign-in');
    }
  }

  @override
  Future<UserProfile> signUpWithEmail(
    String email,
    String password,
    DateTime dateOfBirth,
  ) async {
    try {
      // First verify age
      await verify18Plus(dateOfBirth);

      // Then create the account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile
      final userProfile = UserProfile(
        userId: credential.user!.uid,
        email: email,
        createdAt: DateTime.now(),
        onboardingComplete: false,
        faceDetectionConsentGranted: false,
        biometricConsentGranted: false,
        is18PlusVerified: true,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userProfile.toMap());

      return userProfile;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } on AuthError {
      rethrow;
    } catch (e) {
      throw AuthError('An unexpected error occurred during sign-up');
    }
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    try {
      // TODO: Implement Google Sign-In
      throw UnimplementedError('Google Sign-In not yet implemented');
    } on UnimplementedError {
      throw const AuthError(
        'Google sign-in not yet implemented',
        AuthErrorCode.notImplemented,
      );
    } catch (e) {
      throw AuthError('An unexpected error occurred during Google sign-in');
    }
  }

  @override
  Future<UserProfile> signInWithApple() async {
    try {
      // TODO: Implement Apple Sign-In
      throw UnimplementedError('Apple Sign-In not yet implemented');
    } on UnimplementedError {
      throw const AuthError(
        'Apple sign-in not yet implemented',
        AuthErrorCode.notImplemented,
      );
    } catch (e) {
      throw AuthError('An unexpected error occurred during Apple sign-in');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<UserProfile?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw AuthError('Failed to retrieve user profile');
    }
  }

  @override
  Future<void> upsertUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.userId)
          .set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw AuthError('Failed to save user profile');
    }
  }

  @override
  Future<void> verify18Plus(DateTime dateOfBirth) async {
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year -
        (now.month < dateOfBirth.month ||
                (now.month == dateOfBirth.month && now.day < dateOfBirth.day)
            ? 1
            : 0);

    if (age < 18) {
      throw AuthError(
        'You must be 18 years or older to use this application',
        AuthErrorCode.underAge,
      );
    }
  }

  @override
  Future<void> updateFaceDetectionConsent(bool granted) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthError('User must be signed in to update consent');
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({'faceDetectionConsentGranted': granted}, SetOptions(merge: true));
    } catch (e) {
      throw AuthError('Failed to update face detection consent');
    }
  }

  @override
  Future<void> updateBiometricConsent(bool granted) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthError('User must be signed in to update consent');
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({'biometricConsentGranted': granted}, SetOptions(merge: true));
    } catch (e) {
      throw AuthError('Failed to update biometric consent');
    }
  }

  /// Maps Firebase Auth exceptions to [AuthError].
  AuthError _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AuthError(
          'The email address is already registered. Please sign in.',
          AuthErrorCode.emailAlreadyInUse,
        );
      case 'invalid-email':
        return AuthError(
          'The email address is not valid.',
          AuthErrorCode.invalidEmail,
        );
      case 'weak-password':
        return AuthError(
          'The password is too weak. Please use a stronger password.',
          AuthErrorCode.weakPassword,
        );
      case 'user-disabled':
        return AuthError(
          'This user account has been disabled.',
          AuthErrorCode.userDisabled,
        );
      case 'user-not-found':
        return AuthError(
          'No account found for this email address.',
          AuthErrorCode.userNotFound,
        );
      case 'wrong-password':
        return AuthError(
          'The password is incorrect.',
          AuthErrorCode.wrongPassword,
        );
      case 'operation-not-allowed':
        return AuthError(
          'This authentication method is not allowed.',
          AuthErrorCode.operationNotAllowed,
        );
      default:
        return AuthError(
          'An authentication error occurred. Please try again.',
          AuthErrorCode.generalError,
        );
    }
  }

  /// Gets the user profile from a Firebase User object.
  Future<UserProfile> _getUserProfileFromUser(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }

      // Create a minimal profile if it doesn't exist
      final userProfile = UserProfile(
        userId: user.uid,
        email: user.email ?? '',
        createdAt: DateTime.now(),
        onboardingComplete: false,
        faceDetectionConsentGranted: false,
        biometricConsentGranted: false,
        is18PlusVerified: false,
      );

      await _firestore.collection('users').doc(user.uid).set(userProfile.toMap());

      return userProfile;
    } catch (e) {
      throw AuthError('Failed to retrieve user profile');
    }
  }
}
