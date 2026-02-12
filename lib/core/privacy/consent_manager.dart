

/// Service for managing user consent for various privacy-sensitive operations.
/// 
/// Tracks consent states for:
/// - Face detection (clothing upload)
/// - Biometric processing (virtual try-on)
abstract class ConsentManager {
  /// Checks if face detection consent has been granted.
  Future<bool> hasFaceDetectionConsent();

  /// Records that face detection consent has been granted.
  Future<void> recordFaceDetectionConsent();

  /// Revokes face detection consent.
  Future<void> revokeFaceDetectionConsent();

  /// Checks if biometric consent has been granted.
  Future<bool> hasBiometricConsent();

  /// Records that biometric consent has been granted.
  Future<void> recordBiometricConsent();

  /// Revokes biometric consent.
  Future<void> revokeBiometricConsent();

  /// Clears all consent records.
  Future<void> clearAllConsents();
}

class ConsentManagerImpl implements ConsentManager {
  static const String _faceDetectionConsentKey = 'face_detection_consent';
  static const String _biometricConsentKey = 'biometric_consent';

  final Map<String, bool> _consents = {};

  ConsentManagerImpl();

  @override
  Future<bool> hasFaceDetectionConsent() async {
    return _consents[_faceDetectionConsentKey] ?? false;
  }

  @override
  Future<void> recordFaceDetectionConsent() async {
    _consents[_faceDetectionConsentKey] = true;
  }

  @override
  Future<void> revokeFaceDetectionConsent() async {
    _consents[_faceDetectionConsentKey] = false;
  }

  @override
  Future<bool> hasBiometricConsent() async {
    return _consents[_biometricConsentKey] ?? false;
  }

  @override
  Future<void> recordBiometricConsent() async {
    _consents[_biometricConsentKey] = true;
  }

  @override
  Future<void> revokeBiometricConsent() async {
    _consents[_biometricConsentKey] = false;
  }

  @override
  Future<void> clearAllConsents() async {
    _consents.clear();
  }
}
