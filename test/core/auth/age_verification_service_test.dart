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

    group('Input Validation Tests', () {
      test('should throw ArgumentError when date of birth is in the future', () {
        final referenceDate = DateTime(2024, 1, 15);
        final dateOfBirth = DateTime(2025, 1, 15); // Future date
        
        expect(
          () => service.calculateAgeForTesting(dateOfBirth, referenceDate: referenceDate),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Date of birth cannot be in the future'),
          )),
        );
      });

      test('should throw ArgumentError when age is unreasonable (>150 years)', () {
        final referenceDate = DateTime(2024, 1, 15);
        final dateOfBirth = DateTime(1800, 1, 15); // Too old
        
        expect(
          () => service.calculateAgeForTesting(dateOfBirth, referenceDate: referenceDate),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Maximum supported age is 150 years'),
          )),
        );
      });

      test('should throw ArgumentError when date is before 1900', () {
        final referenceDate = DateTime(2024, 1, 15);
        final dateOfBirth = DateTime(1899, 1, 15); // Before 1900
        
        expect(
          () => service.calculateAgeForTesting(dateOfBirth, referenceDate: referenceDate),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Minimum supported year is 1900'),
          )),
        );
      });

      test('should throw ArgumentError when reference date is too far in future', () {
        final dateOfBirth = DateTime(2000, 1, 15);
        final futureReference = DateTime.now().add(Duration(days: 5)); // 5 days in future
        
        expect(
          () => service.calculateAgeForTesting(dateOfBirth, referenceDate: futureReference),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('more than 1 day in the future'),
          )),
        );
      });

      test('should accept reference date within 1 day in future', () {
        final dateOfBirth = DateTime(2000, 1, 15);
        final futureReference = DateTime.now().add(Duration(hours: 12)); // 12 hours in future
        
        expect(
          () => service.calculateAgeForTesting(dateOfBirth, referenceDate: futureReference),
          returnsNormally,
        );
      });
    });
  });
}

