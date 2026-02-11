import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylesync/core/auth/age_verification_service.dart';
import 'package:stylesync/core/auth/models/auth_error.dart';

class FakeFirestoreChain extends Fake implements FirebaseFirestore {
  final fakeCollection = FakeCollection();
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) => fakeCollection;
}

class FakeCollection extends Fake implements CollectionReference<Map<String, dynamic>> {
  final fakeDoc = FakeDoc();
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) => fakeDoc;
}

class FakeDoc extends Fake implements DocumentReference<Map<String, dynamic>> {
  Map<String, dynamic>? capturedData;
  SetOptions? capturedOptions;
  Map<String, dynamic>? dataToReturn;
  bool shouldThrow = false;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    if (shouldThrow) throw Exception('Firestore error');
    capturedData = data;
    capturedOptions = options;
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    if (shouldThrow) throw Exception('Firestore error');
    return FakeDocumentSnapshot(dataToReturn);
  }
}

class FakeDocumentSnapshot extends Fake implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic>? _data;
  FakeDocumentSnapshot(this._data);

  @override
  bool get exists => _data != null;

  @override
  Map<String, dynamic>? data() => _data;
}

void main() {
  late AgeVerificationServiceImpl service;
  late FakeFirestoreChain fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirestoreChain();
    service = AgeVerificationServiceImpl(firestore: fakeFirestore);
  });

  group('clearCooldown', () {
    test('should use set with merge: true to clear cooldown', () async {
      const userId = 'user123';
      
      await service.clearCooldown(userId);

      expect(fakeFirestore.fakeCollection.fakeDoc.capturedData, 
          containsPair('age_verification_cooldown', isA<FieldValue>()));
      expect(fakeFirestore.fakeCollection.fakeDoc.capturedOptions?.merge, isTrue);
    });

    test('should throw AuthError when set fails', () async {
      const userId = 'user123';
      fakeFirestore.fakeCollection.fakeDoc.shouldThrow = true;

      expect(
        () => service.clearCooldown(userId),
        throwsA(isA<AuthError>()),
      );
    });
  });

  group('verify18PlusSelfReported', () {
    test('should throw AuthError for future date', () async {
      const userId = 'user123';
      final dob = DateTime.now().add(const Duration(days: 1));

      await expectLater(
        () => service.verify18PlusSelfReported(userId, dob),
        throwsA(predicate((e) => e is AuthError && e.code == AuthErrorCode.invalidInput)),
      );

      expect(fakeFirestore.fakeCollection.fakeDoc.capturedData, isNull);
    });

    test('should return true for 18+ and not record cooldown', () async {
      const userId = 'user123';
      final dob = DateTime.now().subtract(const Duration(days: 365 * 20));

      final result = await service.verify18PlusSelfReported(userId, dob);

      expect(result, isTrue);
      expect(fakeFirestore.fakeCollection.fakeDoc.capturedData, isNull);
    });

    test('should throw AuthError and record cooldown for under 18', () async {
      const userId = 'user123';
      final dob = DateTime.now().subtract(const Duration(days: 365 * 10));

      await expectLater(
        () => service.verify18PlusSelfReported(userId, dob),
        throwsA(predicate((e) => e is AuthError && e.code == AuthErrorCode.underAge)),
      );

      expect(fakeFirestore.fakeCollection.fakeDoc.capturedData, 
          containsPair('age_verification_cooldown', isA<FieldValue>()));
    });

    test('should throw AuthError if cooldown is active', () async {
      const userId = 'user123';
      final dob = DateTime.now().subtract(const Duration(days: 365 * 20));

      // Mock active cooldown by having a recent timestamp in the doc
      fakeFirestore.fakeCollection.fakeDoc.dataToReturn = {
        'age_verification_cooldown': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(hours: 12)),
        ),
      };

      await expectLater(
        () => service.verify18PlusSelfReported(userId, dob),
        throwsA(predicate((e) => e is AuthError && e.code == AuthErrorCode.cooldownActive)),
      );
    });
  });

  group('initiateThirdPartyVerification', () {
    test('should use set with merge: true for initiation', () async {
      const userId = 'user123';
      
      await service.initiateThirdPartyVerification(userId);

      expect(fakeFirestore.fakeCollection.fakeDoc.capturedData, 
          containsPair('pendingThirdPartyVerification', true));
      expect(fakeFirestore.fakeCollection.fakeDoc.capturedData, 
          containsPair('thirdPartyVerificationRequestedAt', isA<FieldValue>()));
      expect(fakeFirestore.fakeCollection.fakeDoc.capturedOptions?.merge, isTrue);
    });

    test('should throw AuthError with diagnostics on failure', () async {
      const userId = 'user123';
      fakeFirestore.fakeCollection.fakeDoc.shouldThrow = true;

      await expectLater(
        () => service.initiateThirdPartyVerification(userId),
        throwsA(predicate((e) => e is AuthError && 
            e.code == AuthErrorCode.verificationInitiationFailed &&
            e.message.contains('Firestore error'))),
      );
    });
  });
}
