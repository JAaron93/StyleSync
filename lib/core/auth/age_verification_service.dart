import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/auth_error.dart';

/// Abstract interface for age verification services.
///
/// This service handles 18+ age verification with:
/// - Self-reported DOB verification (primary method)
/// - Third-party ID verification (appeal method)
/// - Session-based cooldown to prevent brute-force attempts
abstract class AgeVerificationService {
  /// Verifies the user is 18+ using self-reported DOB.
  ///
  /// Rejects future dates with [AuthErrorCode.invalidInput].
  /// Enforces a 24-hour cooldown after failed attempts with [AuthErrorCode.cooldownActive].
  /// Returns true if the user is 18+, throws [AuthError] otherwise.
  Future<bool> verify18PlusSelfReported(String userId, DateTime dateOfBirth);

  /// Initiates third-party age verification for appeals.
  ///
  /// This method should be called when a user fails self-reported
  /// verification but believes they are 18+.
  Future<void> initiateThirdPartyVerification(String userId);

  /// Checks if a user has an active cooldown period.
  Future<bool> hasActiveCooldown(String userId);

  /// Clears the cooldown for a user (e.g., after 24 hours).
  Future<void> clearCooldown(String userId);

  /// Calculates the age based on date of birth and an optional reference date (defaults to now).
  int calculateAge(DateTime dateOfBirth, {DateTime? referenceDate});

  /// Marks a user as verified in Firestore.
  Future<void> markUserAsVerified(String userId);
}

/// Implementation of [AgeVerificationService].
class AgeVerificationServiceImpl implements AgeVerificationService {
  /// Creates an [AgeVerificationServiceImpl] instance.
  AgeVerificationServiceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Storage key for cooldown timestamps.
  static const String _kCooldownKey = 'age_verification_cooldown';

  /// Storage key for verification status.
  static const String _kVerifiedKey = 'is18PlusVerified';

  @override
  Future<bool> verify18PlusSelfReported(String userId, DateTime dateOfBirth) async {
    // 1. Validate date
    if (dateOfBirth.isAfter(DateTime.now())) {
      throw const AuthError(
        'Date of birth cannot be in the future',
        AuthErrorCode.invalidInput,
      );
    }

    // 2. Check for active cooldown
    if (await hasActiveCooldown(userId)) {
      throw const AuthError(
        'Too many failed attempts. Please try again in 24 hours.',
        AuthErrorCode.cooldownActive,
      );
    }

    // 3. Calculate age
    final age = calculateAge(dateOfBirth);

    if (age >= 18) {
      return true;
    }

    // 4. Record cooldown for failed attempt
    await _recordCooldown(userId);

    throw const AuthError(
      'You must be 18 years or older to use this application',
      AuthErrorCode.underAge,
    );
  }

  @override
  int calculateAge(DateTime dateOfBirth, {DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    return now.year -
        dateOfBirth.year -
        (now.month < dateOfBirth.month ||
                (now.month == dateOfBirth.month && now.day < dateOfBirth.day)
            ? 1
            : 0);
  }

  /// Records a cooldown timestamp for the given [userId].
  Future<void> _recordCooldown(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        _kCooldownKey: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Fail silent on recording cooldown to avoid blocking verification results
    }
  }

  @override
  Future<void> initiateThirdPartyVerification(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'pendingThirdPartyVerification': true,
        'thirdPartyVerificationRequestedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw AuthError(
        'Failed to initiate third-party verification: ${e.toString()}',
        AuthErrorCode.verificationInitiationFailed,
      );
    }
  }

  @override
  Future<bool> hasActiveCooldown(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return false;
      }

      final cooldownTimestamp = doc.data()?[_kCooldownKey];
      if (cooldownTimestamp == null) {
        return false;
      }

      if (cooldownTimestamp is! Timestamp) {
        return false;
      }
      final cooldownTime = cooldownTimestamp.toDate();
      final now = DateTime.now();
      final hoursSinceCooldown = now.difference(cooldownTime).inHours;

      return hoursSinceCooldown < 24;
    } catch (e) {
      // Fail closed: assume cooldown is active if we can't verify
      // This prevents brute-force during transient failures
      return true;
    }
  }

  @override
  Future<void> clearCooldown(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        _kCooldownKey: FieldValue.delete(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw AuthError('Failed to clear cooldown period');
    }
  }

  @override
  Future<void> markUserAsVerified(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        _kVerifiedKey: true,
      });
    } catch (e) {
      throw AuthError('Failed to mark user as verified');
    }
  }
}
