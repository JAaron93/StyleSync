import 'package:flutter_test/flutter_test.dart';

import 'package:stylesync/core/auth/models/auth_error.dart';
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
}
