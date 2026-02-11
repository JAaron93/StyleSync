import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stylesync/core/auth/auth_service.dart';
import 'package:mockito/mockito.dart'; // We can use Mockito's `Fake` class

// Manual Mocks
class MockUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;

  MockUser({required this.uid, this.email});
}

class MockUserCredential extends Fake implements UserCredential {
  final User _user;
  MockUserCredential(this._user);
  @override
  User? get user => _user;
}

class MockFirebaseAuth extends Fake implements FirebaseAuth {
  final UserCredential _credential;
  MockFirebaseAuth(this._credential);

  @override
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
    return _credential;
  }
}

class MockDocumentSnapshot extends Fake implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  final bool exists;
  @override
  Map<String, dynamic>? data() => null; // Not needed if exists is false

  MockDocumentSnapshot({required this.exists});
}

class MockDocumentReference extends Fake implements DocumentReference<Map<String, dynamic>> {
  final MockDocumentSnapshot _snapshot;
  Map<String, dynamic>? _setData;

  MockDocumentReference(this._snapshot);

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return _snapshot;
  }

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    _setData = data;
  }

  Map<String, dynamic>? get setData => _setData;
}

class MockCollectionReference extends Fake implements CollectionReference<Map<String, dynamic>> {
  final Map<String, MockDocumentReference> _docs = {};

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    if (path == null) throw UnimplementedError();
    return _docs.putIfAbsent(path, () => MockDocumentReference(MockDocumentSnapshot(exists: false)));
  }

  MockDocumentReference? getDocReference(String path) => _docs[path];
}

class MockFirebaseFirestore extends Fake implements FirebaseFirestore {
  final MockCollectionReference _usersCollection = MockCollectionReference();

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    if (path == 'users') return _usersCollection;
    throw UnimplementedError();
  }

  MockCollectionReference get usersCollection => _usersCollection;
}

void main() {
  group('AuthServiceImpl Persistence', () {
    test('signInWithEmail persists minimal profile if it does not exist', () async {
      // Setup
      final mockUser = MockUser(uid: 'test_uid', email: 'test@example.com');
      final mockAuth = MockFirebaseAuth(MockUserCredential(mockUser));
      final mockFirestore = MockFirebaseFirestore();

      final authService = AuthServiceImpl(
        firebaseAuth: mockAuth,
        firebaseFirestore: mockFirestore,
      );

      // Execute
      final profile = await authService.signInWithEmail('test@example.com', 'password');

      // Verify
      // 1. Profile returned matches user
      expect(profile.userId, 'test_uid');
      expect(profile.email, 'test@example.com');

      // 2. Set was called on the document reference
      final docRef = mockFirestore.usersCollection.getDocReference('test_uid');
      expect(docRef, isNotNull);
      expect(docRef!.setData, isNotNull, reason: 'set() should have been called on the document reference');
      
      // 3. Verify the data passed to set
      final persistedData = docRef.setData!;
      expect(persistedData['userId'], 'test_uid');
      expect(persistedData['email'], 'test@example.com');
      expect(persistedData['is18PlusVerified'], false);
    });
  });
}
