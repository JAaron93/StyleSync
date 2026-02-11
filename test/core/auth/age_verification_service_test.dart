import 'package:flutter_test/flutter_test.dart';
import 'package:stylesync/core/auth/age_verification_service.dart';

import 'age_verification_service_test.mocks.dart';

void main() {
  group('AgeVerificationLogic', () {
    late AgeVerificationServiceImpl service;

    setUp(() {
      service = AgeVerificationServiceImpl(firestore: MockFirebaseFirestore());
    });

    test('should calculate age correctly for 20 year old', () {
      final referenceDate = DateTime(2024, 1, 15);
      final dateOfBirth = DateTime(2004, 1, 15);
      
      final age = service.calculateAgeForTesting(dateOfBirth, referenceDate: referenceDate);

      expect(age, 20);
    });

    test('should calculate age correctly for 18 year old (exact)', () {
      final referenceDate = DateTime(2024, 1, 15);
      final dateOfBirth = DateTime(2006, 1, 15);
      
      final age = service.calculateAgeForTesting(dateOfBirth, referenceDate: referenceDate);

      expect(age, 18);
    });

    test('should calculate age correctly for 18 year old (birthday passed)', () {
      final referenceDate = DateTime(2024, 1, 16);
      final dateOfBirth = DateTime(2006, 1, 15);
      
      final age = service.calculateAgeForTesting(dateOfBirth, referenceDate: referenceDate);

      expect(age, 18);
    });

    test('should calculate age correctly for 15 year old', () {
      final referenceDate = DateTime(2024, 1, 15);
      final dateOfBirth = DateTime(2009, 1, 15);
      
      final age = service.calculateAgeForTesting(dateOfBirth, referenceDate: referenceDate);

      expect(age, 15);
    });

    test('should calculate age correctly when birthday has not occurred yet', () {
      final referenceDate = DateTime(2024, 1, 15);
      final dateOfBirth = DateTime(2006, 6, 15);
      
      final age = service.calculateAgeForTesting(dateOfBirth, referenceDate: referenceDate);

      expect(age, 17);
    });
  });
}

