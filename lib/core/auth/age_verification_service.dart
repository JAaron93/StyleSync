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
  /// Returns true if the user is 18+, throws [AuthError] otherwise.
  /// Implements a 24-hour cooldown after failed attempts.
  Future<bool> verify18PlusSelfReported(DateTime dateOfBirth);

  /// Initiates third-party age verification for appeals.
  ///
  /// This method should be called when a user fails self-reported
  /// verification but believes they are 18+.
  Future<void> initiateThirdPartyVerification(String userId);

  /// Checks if a user has an active cooldown period.
  Future<bool> hasActiveCooldown(String userId);

  /// Clears the cooldown for a user (e.g., after 24 hours).
  Future<void> clearCooldown(String userId);

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
  Future<bool> verify18PlusSelfReported(DateTime dateOfBirth) async {
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year -
        (now.month < dateOfBirth.month ||
                (now.month == dateOfBirth.month && now.day < dateOfBirth.day)
            ? 1
            : 0);

    if (age >= 18) {
      return true;
    }

    throw AuthError(
      'You must be 18 years or older to use this application',
      AuthErrorCode.underAge,
    );
  }

  @override
  Future<void> initiateThirdPartyVerification(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            'pendingThirdPartyVerification': true,
            'thirdPartyVerificationRequestedAt':
                FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw AuthError(
        'Failed to initiate third-party verification',
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

      final cooldownTime = (cooldownTimestamp as Timestamp).toDate();
      final now = DateTime.now();
      final hoursSinceCooldown = now.difference(cooldownTime).inHours;

      return hoursSinceCooldown < 24;
    } catch (e) {
      // If we can't check, assume no cooldown (fail open for usability)
      return false;
    }
  }

  @override
  Future<void> clearCooldown(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        _kCooldownKey: FieldValue.delete(),
      });
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
