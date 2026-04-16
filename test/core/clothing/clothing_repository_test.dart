import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stylesync/core/clothing/clothing_repository.dart';
import 'package:stylesync/core/clothing/models/clothing_error.dart';

void main() {
  late ClothingRepositoryImpl repository;
  late FakeFirebaseService fakeFirebase;

  setUp(() {
    fakeFirebase = FakeFirebaseService();
    repository = ClothingRepositoryImpl(
      firestore: fakeFirebase,
      storage: fakeFirebase,
    );
  });

  group('ClothingRepository Upload Flow', () {
    test(
      'uploadClothing returns failure when image file does not exist',
      () async {
        final nonExistentFile = File('/non/existent/path.jpg');

        final result = await repository.uploadClothing(
          nonExistentFile,
          userId: 'test-user-id',
        );

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ClothingValidationError>());
      },
    );

    test(
      'uploadClothing generates idempotency key when not provided',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('clothing_test_');
        final tempFile = File('${tempDir.path}/test_image.jpg');
        await tempFile.writeAsBytes([0xFF, 0xD8, 0xFF]);

        try {
          final result = await repository.uploadClothing(
            tempFile,
            userId: 'test-user-id',
          );

          expect(result.isFailure, false);
          expect(fakeFirebase.storagePutFileCalled, true);
          expect(fakeFirebase.firestoreSetCalled, true);
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );

    test('uploadClothing uses provided idempotency key', () async {
      final tempDir = await Directory.systemTemp.createTemp('clothing_test_');
      final tempFile = File('${tempDir.path}/test_image.jpg');
      await tempFile.writeAsBytes([0xFF, 0xD8, 0xFF]);

      try {
        final idempotencyKey = 'test-idem-key-123';
        final result = await repository.uploadClothing(
          tempFile,
          userId: 'test-user-id',
          idempotencyKey: idempotencyKey,
        );

        expect(result.isFailure, false);
        expect(fakeFirebase.lastIdempotencyKey, idempotencyKey);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });

  group('ClothingRepository CRUD Operations', () {
    // TODO: update tests to stub/mock Firestore responses and verify mockFirestore interactions when replacing placeholder implementation
    test('getClothingItems returns empty list when no items exist', () async {
      fakeFirebase.itemsToReturn = [];
      final result = await repository.getClothingItems(userId: 'user123');

      expect(result.isFailure, false);
      expect(result.valueOrNull, isEmpty);
      expect(fakeFirebase.firestoreGetCalled, true);
    });

    test(
      'getClothingItem returns not found error when item does not exist',
      () async {
        fakeFirebase.itemExists = false;
        final result = await repository.getClothingItem('non-existent-id');

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ClothingItemNotFoundError>());
      },
    );

    test('deleteClothing succeeds without image deletion', () async {
      final result = await repository.deleteClothing('test-id', deleteImage: false);

      expect(result.isFailure, false);
      expect(fakeFirebase.firestoreDeleteCalled, true);
      expect(fakeFirebase.storageDeleteCalled, false);
    });

    test('deleteClothing succeeds with image deletion', () async {
      fakeFirebase.itemExists = true;
      fakeFirebase.itemToReturn = {
        'id': 'test-id',
        'userId': 'user123',
        'imageUrl': 'https://example.com/image.jpg',
        'processedImageUrl': 'https://example.com/proc.jpg',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
        'category': 'tops',
        'colors': [],
        'seasons': [],
        'uploadedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'processingState': 'completed',
        'idempotencyKey': 'key',
      };

      final result = await repository.deleteClothing('test-id', deleteImage: true);

      expect(result.isFailure, false);
      expect(fakeFirebase.firestoreDeleteCalled, true);
      expect(fakeFirebase.storageDeleteCalled, true);
    });

    test('deleteClothing fails when item not found and deleteImage is true', () async {
      fakeFirebase.itemExists = false;
      
      final result = await repository.deleteClothing('non-existent', deleteImage: true);

      expect(result.isFailure, true);
      expect(result.errorOrNull, isA<ClothingItemNotFoundError>());
      expect(fakeFirebase.firestoreDeleteCalled, false);
      expect(fakeFirebase.storageDeleteCalled, false);
    });

    test('updateClothing succeeds and triggers firestoreUpdateCalled', () async {
      final itemId = 'test-item-id';
      final updates = ClothingItem.create(
        userId: 'user123',
        imageUrl: 'https://example.com/updated.jpg',
        processedImageUrl: 'https://example.com/updated_proc.jpg',
        thumbnailUrl: 'https://example.com/updated_thumb.jpg',
        category: 'bottoms',
        colors: ['black'],
        seasons: ['winter'],
        idempotencyKey: 'new-key',
      );

      fakeFirebase.itemToReturn = updates.toJson();
      final result = await repository.updateClothing(itemId, updates);

      expect(result.isFailure, false);
      expect(fakeFirebase.firestoreUpdateCalled, true);
      expect(fakeFirebase.firestoreSetCalled, false);
      expect(fakeFirebase.capturedUpdateData, updates.toJson());
    });

    test('retryProcessing returns failure for non-existent item', () async {
      fakeFirebase.itemExists = false;
      final result = await repository.retryProcessing('test-id');
      expect(result.isFailure, true);
    });
  });

  group('ClothingRepository Storage Quota', () {
    test('getStorageQuota returns quota with correct limits', () async {
      fakeFirebase.itemsToReturn = [];
      final result = await repository.getStorageQuota('user123');

      expect(result.isFailure, false);
      final quota = result.valueOrNull!;
      expect(quota.maxItems, 500);
      expect(quota.itemCount, 0);
    });
  });
}

// FULL MANUAL FAKES FOR FIREBASE (NO MOCKITO)

class FakeFirebaseService extends Fake
    implements FirebaseFirestore, FirebaseStorage {
  // Verification states
  bool firestoreSetCalled = false;
  bool firestoreUpdateCalled = false;
  bool firestoreDeleteCalled = false;
  bool firestoreGetCalled = false;
  bool storagePutFileCalled = false;
  bool storageDeleteCalled = false;
  String? lastIdempotencyKey;
  Map<Object, Object?>? capturedUpdateData;
  Map<String, dynamic>? lastFirestoreSetData;
  
  // Return configuration
  bool itemExists = true;
  List<Map<String, dynamic>> itemsToReturn = [];
  Map<String, dynamic>? itemToReturn;
  Object? storageUploadError;
  String downloadUrlToReturn = 'https://example.com/image.jpg';

  // Firestore implementation
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      FakeCollectionReference(this);

  // Storage implementation
  @override
  Reference ref([String? path]) => FakeReference(this);

  @override
  Reference refFromURL(String url) => FakeReference(this);
}

class FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final FakeFirebaseService _service;
  FakeCollectionReference(this._service);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      FakeDocumentReference(_service);

  @override
  Query<Map<String, dynamic>> where(Object field,
          {Object? isEqualTo,
          Object? isNotEqualTo,
          Object? isLessThan,
          Object? isLessThanOrEqualTo,
          Object? isGreaterThan,
          Object? isGreaterThanOrEqualTo,
          Object? arrayContains,
          Iterable<Object?>? arrayContainsAny,
          Iterable<Object?>? whereIn,
          Iterable<Object?>? whereNotIn,
          bool? isNull}) =>
      this;

  @override
  Query<Map<String, dynamic>> orderBy(Object field, {bool descending = false}) =>
      this;

  @override
  Query<Map<String, dynamic>> limit(int limit) => this;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    _service.firestoreGetCalled = true;
    return FakeQuerySnapshot(_service.itemsToReturn);
  }
}

class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  final FakeFirebaseService _service;
  FakeDocumentReference(this._service);

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    _service.firestoreSetCalled = true;
    _service.lastFirestoreSetData = data;
    _service.lastIdempotencyKey = data['idempotencyKey']?.toString();
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    _service.firestoreUpdateCalled = true;
    _service.capturedUpdateData = data;
  }

  @override
  Future<void> delete() async {
    _service.firestoreDeleteCalled = true;
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    _service.firestoreGetCalled = true;
    final Map<String, dynamic> data;
    if (_service.itemExists) {
      if (_service.itemToReturn != null) {
        data = _service.itemToReturn!;
      } else if (_service.itemsToReturn.isNotEmpty) {
        data = _service.itemsToReturn.first;
      } else {
        data = {};
      }
    } else {
      data = {};
    }
    return FakeDocumentSnapshot(_service.itemExists, data);
  }
}

class FakeReference extends Fake implements Reference {
  final FakeFirebaseService _service;
  FakeReference(this._service);

  @override
  Reference child(String path) => this;

  @override
  UploadTask putFile(File file, [SettableMetadata? metadata]) {
    _service.storagePutFileCalled = true;
    return FakeUploadTask(
      error: _service.storageUploadError,
      snapshot: FakeTaskSnapshot(this),
    );
  }

  @override
  Future<String> getDownloadURL() async {
    return _service.downloadUrlToReturn;
  }

  @override
  Future<void> delete() async {
    _service.storageDeleteCalled = true;
  }
}

class FakeQuerySnapshot extends Fake
    implements QuerySnapshot<Map<String, dynamic>> {
  final List<Map<String, dynamic>> _items;
  FakeQuerySnapshot(this._items);

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs =>
      _items.map((data) => FakeQueryDocumentSnapshot(data)).toList();

  @override
  int get size => _items.length;
}

class FakeQueryDocumentSnapshot extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  FakeQueryDocumentSnapshot(this._data);

  @override
  Map<String, dynamic> data() => _data;
}

class FakeDocumentSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  final bool exists;
  final Map<String, dynamic> _data;

  FakeDocumentSnapshot(this.exists, this._data);

  @override
  Map<String, dynamic>? data() => exists ? _data : null;
}

class FakeUploadTask extends Fake implements UploadTask {
  final Object? error;
  final FakeTaskSnapshot snapshot;

  FakeUploadTask({this.error, required this.snapshot});

  @override
  Future<S> then<S>(FutureOr<S> Function(TaskSnapshot) onValue,
          {Function? onError}) async {
    if (error != null) {
      if (onError != null) {
        return onError(error!) as FutureOr<S>;
      }
      throw error!;
    }
    return onValue(snapshot);
  }
}

class FakeTaskSnapshot extends Fake implements TaskSnapshot {
  final Reference _ref;

  FakeTaskSnapshot(this._ref);

  @override
  Reference get ref => _ref;
}
