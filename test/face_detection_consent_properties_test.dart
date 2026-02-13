import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylesync/core/privacy/consent_manager.dart';
import 'package:stylesync/features/privacy/widgets/face_detection_consent_dialog.dart';

void main() {
  group('Property Tests: Face Detection Consent Enforcement', () {
    final consentManager = ConsentManagerImpl();

    tearDown(() {
      // Reset persistent state after each test
      consentManager.clearAllConsents();
    });

    // Property 5: Face Detection Consent Enforcement
    testWidgets('FaceDetectionConsentDialog renders correctly', (WidgetTester tester) async {
      bool consentGranted = false;
      bool consentRejected = false;

      // Given: A consent dialog wrapped in MaterialApp
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FaceDetectionConsentDialog(
              onConsentGranted: () => consentGranted = true,
              onConsentRejected: () => consentRejected = true,
            ),
          ),
        ),
      );

      // Then: The dialog should be present
      expect(find.byType(FaceDetectionConsentDialog), findsOneWidget);

      // Check UI elements are present
      expect(find.text('Face Detection Consent'), findsOneWidget);
      expect(find.text('To provide face detection features, we need to process your photo.'), findsOneWidget);
      expect(find.text('Processing happens on-device with direct client-to-AI communication.'), findsOneWidget);
      expect(find.text('Your input photo is ephemeral and deleted immediately after processing.'), findsOneWidget);
      expect(find.text('Generated results are stored only if you explicitly save them.'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.text('Grant Consent'), findsOneWidget);

      // When: User taps Reject button
      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      // Then: onConsentRejected should be called
      expect(consentRejected, isTrue);
      expect(consentGranted, isFalse);

      // Reset and test Grant button
      consentGranted = false;
      consentRejected = false;

      // When: User taps Grant Consent button
      await tester.tap(find.text('Grant Consent'));
      await tester.pumpAndSettle();

      // Then: onConsentGranted should be called
      expect(consentGranted, isTrue);
      expect(consentRejected, isFalse);
    });

    test('Biometric consent is tracked separately from face detection consent', () async {
      // Given: A new consent manager
      final consentManager = ConsentManagerImpl();

      // When: Check initial state
      final faceDetectionConsent = await consentManager.hasFaceDetectionConsent();
      final biometricConsent = await consentManager.hasBiometricConsent();

      // Then: Both should be false initially
      expect(faceDetectionConsent, isFalse);
      expect(biometricConsent, isFalse);

      // When: User grants face detection consent
      await consentManager.recordFaceDetectionConsent();

      // Then: Only face detection consent should be true
      final faceDetectionConsent2 = await consentManager.hasFaceDetectionConsent();
      final biometricConsent2 = await consentManager.hasBiometricConsent();

      expect(faceDetectionConsent2, isTrue);
      expect(biometricConsent2, isFalse);

      // When: User grants biometric consent
      await consentManager.recordBiometricConsent();

      // Then: Both should be true
      final faceDetectionConsent3 = await consentManager.hasFaceDetectionConsent();
      final biometricConsent3 = await consentManager.hasBiometricConsent();

      expect(faceDetectionConsent3, isTrue);
      expect(biometricConsent3, isTrue);
    });

    test('Consent manager clears all consents correctly', () async {
      // Given: User has granted both consents
      final consentManager = ConsentManagerImpl();
      await consentManager.recordFaceDetectionConsent();
      await consentManager.recordBiometricConsent();

      // When: All consents are cleared
      await consentManager.clearAllConsents();

      // Then: Both consents should be false
      final faceDetectionConsent = await consentManager.hasFaceDetectionConsent();
      final biometricConsent = await consentManager.hasBiometricConsent();

      expect(faceDetectionConsent, isFalse);
      expect(biometricConsent, isFalse);
    });
  });
}
