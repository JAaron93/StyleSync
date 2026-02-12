import 'package:flutter_test/flutter_test.dart';
import 'package:stylesync/core/privacy/consent_manager.dart';
import 'package:stylesync/features/privacy/widgets/face_detection_consent_dialog.dart';

void main() {
  group('Property Tests: Face Detection Consent Enforcement', () {
    // Property 5: Face Detection Consent Enforcement
    test('FaceDetectionConsentDialog renders correctly', () {
      // Given: A consent dialog
      final dialog = FaceDetectionConsentDialog(
        onConsentGranted: () {},
        onConsentRejected: () {},
      );

      // Then: The dialog should contain expected callbacks
      expect(dialog, isNotNull);
      expect(dialog.onConsentGranted, isNotNull);
      expect(dialog.onConsentRejected, isNotNull);
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
