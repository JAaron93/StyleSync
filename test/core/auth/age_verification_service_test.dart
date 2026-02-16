import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stylesync/core/auth/age_verification_service.dart';

import 'age_verification_service_test.mocks.dart';

@GenerateMocks([FirebaseFirestore])

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

    group('Edge Case Tests', () {
      test('should handle Feb 29 birthday on non-leap year (evaluated on Feb 28)', () {
        // Born Feb 29, 2004 (leap year) - would turn 19 on Feb 29, 2023
        // But 2023 is not a leap year, so Feb 28 is before the "birthday"
        final dateOfBirth = DateTime(2004, 2, 29);
        final referenceDate = DateTime(2023, 2, 28);
        
        final age = service.calculateAgeForTesting(dateOfBirth, referenceDate: referenceDate);

        // On Feb 28, birthday (Feb 29) hasn't occurred yet, so age is 18
        expect(age, 18);
      });

      test('should handle Feb 29 birthday on non-leap year (evaluated on Mar 1)', () {
        // Born Feb 29, 2004 (leap year) - would turn 19 on Feb 29, 2023
        // But 2023 is not a leap year, so Mar 1 is after the "birthday"
        final dateOfBirth = DateTime(2004, 2, 29);
        final referenceDate = DateTime(2023, 3, 1);
        
        final age = service.calculateAgeForTesting(dateOfBirth, referenceDate: referenceDate);

        // On Mar 1, birthday has passed, so age is 19
        expect(age, 19);
      });

      test('should handle year-boundary transition (Dec 31 birthday, Jan 1 reference)', () {
        // Born Dec 31, 2000 - turns 1 on Dec 31, 2001
        // On Jan 1, 2001, birthday hasn't occurred yet
        final dateOfBirth = DateTime(2000, 12, 31);
        final referenceDate = DateTime(2001, 1, 1);
        
        final age = service.calculateAgeForTesting(dateOfBirth, referenceDate: referenceDate);

        // On Jan 1, 2001, still 0 years old (birthday Dec 31 not yet occurred)
        expect(age, 0);
      });

      test('should handle year-boundary transition (Jan 1 birthday, Dec 31 reference)', () {
        // Born Jan 1, 2000 - turns 1 on Jan 1, 2001
        // On Dec 31, 2000, birthday hasn't occurred yet
        final dateOfBirth = DateTime(2000, 1, 1);
        final referenceDate = DateTime(2000, 12, 31);
        
        final age = service.calculateAgeForTesting(dateOfBirth, referenceDate: referenceDate);

        // On Dec 31, 2000, still 0 years old (birthday Jan 1 not yet occurred)
        expect(age, 0);
      });
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

