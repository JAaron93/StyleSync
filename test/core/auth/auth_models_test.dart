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

      expect(user1.hashCode, user2.hashCode);
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
