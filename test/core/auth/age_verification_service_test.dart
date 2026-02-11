import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgeVerificationLogic', () {
    test('should calculate age correctly for 20 year old', () {
      final referenceDate = DateTime(2024, 1, 15);
      final dateOfBirth = DateTime(2004, 1, 15);
      final age = referenceDate.year - dateOfBirth.year -
          (referenceDate.month < dateOfBirth.month ||
                  (referenceDate.month == dateOfBirth.month && referenceDate.day < dateOfBirth.day)
              ? 1
              : 0);

      expect(age, 20);
    });

    test('should calculate age correctly for 18 year old (exact)', () {
      final referenceDate = DateTime(2024, 1, 15);
      final dateOfBirth = DateTime(2006, 1, 15);
      final age = referenceDate.year - dateOfBirth.year -
          (referenceDate.month < dateOfBirth.month ||
                  (referenceDate.month == dateOfBirth.month && referenceDate.day < dateOfBirth.day)
              ? 1
              : 0);

      expect(age, 18);
    });

    test('should calculate age correctly for 18 year old (birthday passed)', () {
      final referenceDate = DateTime(2024, 1, 16);
      final dateOfBirth = DateTime(2006, 1, 15);
      final age = referenceDate.year - dateOfBirth.year -
          (referenceDate.month < dateOfBirth.month ||
                  (referenceDate.month == dateOfBirth.month && referenceDate.day < dateOfBirth.day)
              ? 1
              : 0);

      expect(age, 18);
    });

    test('should calculate age correctly for 15 year old', () {
      final referenceDate = DateTime(2024, 1, 15);
      final dateOfBirth = DateTime(2009, 1, 15);
      final age = referenceDate.year - dateOfBirth.year -
          (referenceDate.month < dateOfBirth.month ||
                  (referenceDate.month == dateOfBirth.month && referenceDate.day < dateOfBirth.day)
              ? 1
              : 0);

      expect(age, 15);
    });

    test('should calculate age correctly when birthday has not occurred yet', () {
      final referenceDate = DateTime(2024, 1, 15);
      final dateOfBirth = DateTime(2006, 6, 15);
      final age = referenceDate.year - dateOfBirth.year -
          (referenceDate.month < dateOfBirth.month ||
                  (referenceDate.month == dateOfBirth.month && referenceDate.day < dateOfBirth.day)
              ? 1
              : 0);

      expect(age, 17);
    });
  });
}
