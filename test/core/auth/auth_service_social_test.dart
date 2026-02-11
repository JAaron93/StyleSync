import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stylesync/core/auth/auth_service.dart';
import 'package:stylesync/core/auth/models/auth_error.dart';

class FakeFirebaseAuth extends Fake implements FirebaseAuth {}
class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {}

void main() {
  group('AuthService Social Auth', () {
    late AuthService authService;

    setUp(() {
      authService = AuthServiceImpl(
        firebaseAuth: FakeFirebaseAuth(),
        firebaseFirestore: FakeFirebaseFirestore(),
      );
    });

    test('signInWithGoogle throws AuthError.notImplemented', () async {
      expect(
        () => authService.signInWithGoogle(),
        throwsA(isA<AuthError>().having(
          (e) => e.code,
          'code',
          AuthErrorCode.notImplemented,
        )),
      );
    });

    test('signInWithApple throws AuthError.notImplemented', () async {
      expect(
        () => authService.signInWithApple(),
        throwsA(isA<AuthError>().having(
          (e) => e.code,
          'code',
          AuthErrorCode.notImplemented,
        )),
      );
    });
  });
}
