import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's profile in the system.
///
/// This model stores user-related information including authentication
/// status, onboarding completion, and age verification state.
class UserProfile {
  /// Creates a [UserProfile] instance.
  const UserProfile({
    required this.userId,
    required this.email,
    required this.createdAt,
    required this.onboardingComplete,
    required this.faceDetectionConsentGranted,
    required this.biometricConsentGranted,
    required this.is18PlusVerified,
  });

  /// The unique Firebase Auth UID for this user.
  final String userId;

  /// The user's email address.
  final String email;

  /// When the user account was created.
  final DateTime createdAt;

  /// Whether the user has completed the onboarding flow.
  final bool onboardingComplete;

  /// Whether the user has granted face detection consent.
  final bool faceDetectionConsentGranted;

  /// Whether the user has granted biometric consent for try-on features.
  final bool biometricConsentGranted;

  /// Whether the user has been verified as 18+ years old.
  final bool is18PlusVerified;

  /// Creates a copy of this profile with the given fields replaced.
  UserProfile copyWith({
    String? userId,
    String? email,
    DateTime? createdAt,
    bool? onboardingComplete,
    bool? faceDetectionConsentGranted,
    bool? biometricConsentGranted,
    bool? is18PlusVerified,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      faceDetectionConsentGranted:
          faceDetectionConsentGranted ?? this.faceDetectionConsentGranted,
      biometricConsentGranted:
          biometricConsentGranted ?? this.biometricConsentGranted,
      is18PlusVerified: is18PlusVerified ?? this.is18PlusVerified,
    );
  }

  /// Converts the profile to a map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'onboardingComplete': onboardingComplete,
      'faceDetectionConsentGranted': faceDetectionConsentGranted,
      'biometricConsentGranted': biometricConsentGranted,
      'is18PlusVerified': is18PlusVerified,
    };
  }

  /// Creates a [UserProfile] from a Firestore document map.
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final userId = map['userId'];
    final email = map['email'];
    final createdAt = map['createdAt'];
    final onboardingComplete = map['onboardingComplete'];
    final faceDetectionConsentGranted = map['faceDetectionConsentGranted'];
    final biometricConsentGranted = map['biometricConsentGranted'];
    final is18PlusVerified = map['is18PlusVerified'];

    if (userId is! String ||
        email is! String ||
        (createdAt is! String && createdAt is! Timestamp) ||
        onboardingComplete is! bool ||
        faceDetectionConsentGranted is! bool ||
        biometricConsentGranted is! bool ||
        is18PlusVerified is! bool) {
      throw FormatException('Invalid UserProfile data: $map');
    }

    DateTime createdAtDateTime;
    if (createdAt is Timestamp) {
      createdAtDateTime = createdAt.toDate();
    } else {
      try {
        createdAtDateTime = DateTime.parse(createdAt);
      } catch (e) {
        throw FormatException('Invalid UserProfile data: $map');
      }
    }

    return UserProfile(
      userId: userId,
      email: email,
      createdAt: createdAtDateTime,
      onboardingComplete: onboardingComplete,
      faceDetectionConsentGranted: faceDetectionConsentGranted,
      biometricConsentGranted: biometricConsentGranted,
      is18PlusVerified: is18PlusVerified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.userId == userId &&
        other.email == email &&
        other.createdAt == createdAt &&
        other.onboardingComplete == onboardingComplete &&
        other.faceDetectionConsentGranted == faceDetectionConsentGranted &&
        other.biometricConsentGranted == biometricConsentGranted &&
        other.is18PlusVerified == is18PlusVerified;
  }

  @override
  int get hashCode => Object.hash(
        userId,
        email,
        createdAt,
        onboardingComplete,
        faceDetectionConsentGranted,
        biometricConsentGranted,
        is18PlusVerified,
      );

  @override
  String toString() {
    return 'UserProfile(userId: $userId, email: *****, createdAt: $createdAt, onboardingComplete: $onboardingComplete, faceDetectionConsentGranted: $faceDetectionConsentGranted, biometricConsentGranted: $biometricConsentGranted, is18PlusVerified: $is18PlusVerified)';
  }
}
