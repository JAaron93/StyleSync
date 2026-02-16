import 'package:flutter_test/flutter_test.dart';

import 'package:stylesync/core/auth/models/auth_error.dart';
import 'package:stylesync/core/auth/models/auth_user.dart';
import 'package:stylesync/core/auth/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('should create a valid user profile', () {
      final profile = UserProfile(
        userId: 'user123',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        onboardingComplete: true,
        faceDetectionConsentGranted: true,
        biometricConsentGranted: true,
        is18PlusVerified: true,
      );

      expect(profile.userId, 'user123');
      expect(profile.email, 'test@example.com');
      expect(profile.is18PlusVerified, true);
    });

    test('should convert to and from map', () {
      final profile = UserProfile(
        userId: 'user123',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        onboardingComplete: true,
        faceDetectionConsentGranted: true,
        biometricConsentGranted: true,
        is18PlusVerified: true,
      );

      final map = profile.toMap();
      final restored = UserProfile.fromMap(map);

      // Field-level assertions for clearer failure messages
      expect(restored.userId, profile.userId, reason: 'userId should round-trip');
      expect(restored.email, profile.email, reason: 'email should round-trip');
      expect(restored.createdAt, profile.createdAt, reason: 'createdAt should round-trip');
      expect(restored.onboardingComplete, profile.onboardingComplete, reason: 'onboardingComplete should round-trip');
      expect(restored.faceDetectionConsentGranted, profile.faceDetectionConsentGranted, reason: 'faceDetectionConsentGranted should round-trip');
      expect(restored.biometricConsentGranted, profile.biometricConsentGranted, reason: 'biometricConsentGranted should round-trip');
      expect(restored.is18PlusVerified, profile.is18PlusVerified, reason: 'is18PlusVerified should round-trip');
      // Overall equality check
      expect(restored, profile);
    });

    test('should copy with updated fields', () {
      final profile = UserProfile(
        userId: 'user123',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        onboardingComplete: false,
        faceDetectionConsentGranted: false,
        biometricConsentGranted: false,
        is18PlusVerified: false,
      );

      final updated = profile.copyWith(
        onboardingComplete: true,
        faceDetectionConsentGranted: true,
      );

      expect(updated.onboardingComplete, true);
      expect(updated.faceDetectionConsentGranted, true);
      expect(updated.email, 'test@example.com');
    });

    test('should allow setting dateOfBirth via copyWith', () {
      final profile = UserProfile(
        userId: 'user123',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        onboardingComplete: true,
        faceDetectionConsentGranted: true,
        biometricConsentGranted: true,
        is18PlusVerified: true,
      );

      expect(profile.dateOfBirth, isNull);

      final updated = profile.copyWith(
        dateOfBirth: DateTime(1990, 5, 15),
      );

      expect(updated.dateOfBirth, DateTime(1990, 5, 15));
    });

    test('should preserve dateOfBirth when not specified in copyWith', () {
      final profile = UserProfile(
        userId: 'user123',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        onboardingComplete: true,
        faceDetectionConsentGranted: true,
        biometricConsentGranted: true,
        is18PlusVerified: true,
        dateOfBirth: DateTime(1990, 5, 15),
      );

      final updated = profile.copyWith(
        onboardingComplete: false,
      );

      expect(updated.dateOfBirth, DateTime(1990, 5, 15));
    });

    test('should clear dateOfBirth when clearDateOfBirth is true', () {
      final profile = UserProfile(
        userId: 'user123',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        onboardingComplete: true,
        faceDetectionConsentGranted: true,
        biometricConsentGranted: true,
        is18PlusVerified: true,
        dateOfBirth: DateTime(1990, 5, 15),
      );

      final updated = profile.copyWith(clearDateOfBirth: true);

      expect(updated.dateOfBirth, isNull);
    });

    test('should not clear dateOfBirth when clearDateOfBirth is false', () {
      final profile = UserProfile(
        userId: 'user123',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        onboardingComplete: true,
        faceDetectionConsentGranted: true,
        biometricConsentGranted: true,
        is18PlusVerified: true,
        dateOfBirth: DateTime(1990, 5, 15),
      );

      final updated = profile.copyWith(clearDateOfBirth: false);

      expect(updated.dateOfBirth, DateTime(1990, 5, 15));
    });

    test('dateOfBirth parameter takes precedence over clearDateOfBirth', () {
      final profile = UserProfile(
        userId: 'user123',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        onboardingComplete: true,
        faceDetectionConsentGranted: true,
        biometricConsentGranted: true,
        is18PlusVerified: true,
        dateOfBirth: DateTime(1990, 5, 15),
      );

      final updated = profile.copyWith(
        dateOfBirth: DateTime(2000, 1, 1),
        clearDateOfBirth: true, // Should be ignored since dateOfBirth is provided
      );

      expect(updated.dateOfBirth, DateTime(2000, 1, 1));
    });
  });

  group('AuthError', () {
    test('should create an error with message', () {
      final error = AuthError('Test error message');
      expect(error.message, 'Test error message');
      expect(error.code, isNull);
    });

    test('should create an error with message and code', () {
      final error = AuthError('Test error message', 'ERROR_CODE');
      expect(error.message, 'Test error message');
      expect(error.code, 'ERROR_CODE');
    });

    test('should have proper toString', () {
      final error = AuthError('Test error message', 'ERROR_CODE');
      expect(error.toString(), contains('AuthError(ERROR_CODE): Test error message'));
    });

    test('should have proper toString when code is null', () {
      final error = AuthError('Test error message');
      final result = error.toString();
      expect(result, contains('AuthError'));
      expect(result, contains('Test error message'));
      expect(result, isNot(contains('(null)')));
      expect(result, equals('AuthError: Test error message'));
    });
  });

  group('AuthUser', () {
    test('should create a user with required id', () {
      final user = AuthUser(id: 'user123');
      expect(user.id, 'user123');
      expect(user.email, isNull);
      expect(user.displayName, isNull);
    });

    test('should create a user with all fields', () {
      final user = AuthUser(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      expect(user.id, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
    });

    test('should implement equality', () {
      final user1 = AuthUser(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      final user2 = AuthUser(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      final user3 = AuthUser(id: 'user456');

      expect(user1, user2);
      expect(user1, isNot(user3));
    });

    test('should have consistent hashCode', () {
      final user1 = AuthUser(id: 'user123', email: 'test@example.com');
      final user2 = AuthUser(id: 'user123', email: 'test@example.com');

      // Verify hashCode is stable across multiple calls on the same instance
      final user1HashCode1 = user1.hashCode;
      final user1HashCode2 = user1.hashCode;
      final user1HashCode3 = user1.hashCode;
      expect(user1HashCode1, user1HashCode2, reason: 'user1.hashCode should be stable');
      expect(user1HashCode1, user1HashCode3, reason: 'user1.hashCode should be stable');

      final user2HashCode1 = user2.hashCode;
      final user2HashCode2 = user2.hashCode;
      expect(user2HashCode1, user2HashCode2, reason: 'user2.hashCode should be stable');

      // Verify equal instances have equal hashCodes
      expect(user1HashCode1, user2HashCode1, reason: 'Equal instances should have equal hashCodes');
    });

    test('should have proper toString', () {
      final user = AuthUser(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      expect(user.toString(), contains('user123'));
      expect(user.toString(), contains('test@example.com'));
      expect(user.toString(), contains('Test User'));
    });
  });
}
