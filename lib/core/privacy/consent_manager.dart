import 'package:shared_preferences/shared_preferences.dart';

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

  final SharedPreferences _prefs;

  ConsentManagerImpl(this._prefs);

  @override
  Future<bool> hasFaceDetectionConsent() async {
    return _prefs.getBool(_faceDetectionConsentKey) ?? false;
  }

  @override
  Future<void> recordFaceDetectionConsent() async {
    await _prefs.setBool(_faceDetectionConsentKey, true);
  }

  @override
  Future<void> revokeFaceDetectionConsent() async {
    await _prefs.setBool(_faceDetectionConsentKey, false);
  }

  @override
  Future<bool> hasBiometricConsent() async {
    return _prefs.getBool(_biometricConsentKey) ?? false;
  }

  @override
  Future<void> recordBiometricConsent() async {
    await _prefs.setBool(_biometricConsentKey, true);
  }

  @override
  Future<void> revokeBiometricConsent() async {
    await _prefs.setBool(_biometricConsentKey, false);
  }

  @override
  Future<void> clearAllConsents() async {
    await _prefs.remove(_faceDetectionConsentKey);
    await _prefs.remove(_biometricConsentKey);
  }
}
