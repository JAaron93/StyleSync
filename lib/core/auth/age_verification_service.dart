import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'models/auth_error.dart';

/// Logger for age verification operations.
final Logger _logger = Logger('AgeVerificationService');

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

  /// Clears cooldown for a user (e.g., after 24 hours).
  Future<void> clearCooldown(String userId);

  /// Marks a user as verified in Firestore.
  Future<void> markUserAsVerified(String userId);

  /// Calculates age based on date of birth and an optional reference date (defaults to now).
  /// 
  /// This method is exposed for testing purposes only.
  /// In production code, use [verify18PlusSelfReported] instead.
  @visibleForTesting
  int calculateAgeForTesting(DateTime dateOfBirth, {DateTime? referenceDate});
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
    final age = _calculateAge(dateOfBirth);

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

  /// Calculates age based on date of birth and an optional reference date (defaults to now).
  int _calculateAge(DateTime dateOfBirth, {DateTime? referenceDate}) {
    // Input validation
    _validateDateInputs(dateOfBirth, referenceDate);
    
    final now = referenceDate ?? DateTime.now();
    return now.year -
        dateOfBirth.year -
        (now.month < dateOfBirth.month ||
                (now.month == dateOfBirth.month && now.day < dateOfBirth.day)
            ? 1
            : 0);
  }

  /// Validates date inputs for age calculation.
  /// 
  /// Throws [ArgumentError] if dates are invalid or unreasonable.
  void _validateDateInputs(DateTime dateOfBirth, DateTime? referenceDate) {
    final now = referenceDate ?? DateTime.now();
    
    // Check if date of birth is in the future
    if (dateOfBirth.isAfter(now)) {
      throw ArgumentError(
        'Date of birth cannot be in the future. Provided: ${dateOfBirth.toIso8601String()}, '
        'Reference: ${now.toIso8601String()}'
      );
    }
    
    // Check for unreasonable ages (e.g., older than 150 years)
    final maxReasonableAge = 150;
    final calculatedAge = now.year - dateOfBirth.year;
    if (calculatedAge > maxReasonableAge) {
      throw ArgumentError(
        'Date of birth indicates an unreasonable age. Maximum supported age is $maxReasonableAge years. '
        'Provided date: ${dateOfBirth.toIso8601String()}'
      );
    }
    
    // Check for dates that are too far in the past (before year 1900)
    final minReasonableYear = 1900;
    if (dateOfBirth.year < minReasonableYear) {
      throw ArgumentError(
        'Date of birth is too far in the past. Minimum supported year is $minReasonableYear. '
        'Provided year: ${dateOfBirth.year}'
      );
    }
    
    // Validate that reference date is not in the distant future (more than 1 day from now)
    if (referenceDate != null) {
      final maxFutureDelta = Duration(days: 1);
      final futureDifference = referenceDate.difference(DateTime.now());
      if (futureDifference > maxFutureDelta) {
        throw ArgumentError(
          'Reference date cannot be more than ${maxFutureDelta.inDays} days in the future. '
          'Provided: ${referenceDate.toIso8601String()}'
        );
      }
    }
  }

  /// Records a cooldown timestamp for the given [userId].
  Future<void> _recordCooldown(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        _kCooldownKey: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Fail silent on recording cooldown to avoid blocking verification results
      // but log for observability
      _logger.warning('Failed to record cooldown for user $userId', e);
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
      _logger.warning('Failed to initiate third-party verification for user $userId: ${e.toString()}', e);
      throw AuthError(
        'Failed to initiate third-party verification for user $userId: ${e.toString()}',
        AuthErrorCode.thirdPartyInitiationFailed,
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
        // Fail closed: if timestamp exists but is corrupted, assume cooldown is active
        return true;
      }
      final cooldownTime = cooldownTimestamp.toDate();
      final now = DateTime.now();
      final hoursSinceCooldown = now.difference(cooldownTime).inHours;

      return hoursSinceCooldown < 24;
    } catch (e) {
      // Fail closed: assume cooldown is active if we can't verify
      // This prevents brute-force during transient failures
      // Log for observability
      _logger.warning('Failed to check cooldown status for user $userId, assuming active', e);
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
      throw AuthError('Failed to clear cooldown period: ${e.toString()}');
    }
  }

  @override
  Future<void> markUserAsVerified(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        _kVerifiedKey: true,
      }, SetOptions(merge: true));
    } catch (e) {
      throw AuthError('Failed to mark user as verified: ${e.toString()}');
    }
  }

  @override
  int calculateAgeForTesting(DateTime dateOfBirth, {DateTime? referenceDate}) {
    return _calculateAge(dateOfBirth, referenceDate: referenceDate);
  }
}
