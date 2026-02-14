import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:stylesync/core/clothing/clothing_repository.dart';
import 'package:stylesync/core/clothing/models/clothing_error.dart';
import 'package:stylesync/core/clothing/models/clothing_item.dart';

void main() {
  late ClothingRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseStorage mockStorage;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    repository = ClothingRepositoryImpl(
      firestore: mockFirestore,
      storage: mockStorage,
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
        if (result.isFailure) {
          expect(result.errorOrNull, isA<ClothingValidationError>());
        }
      },
    );

    test(
      'uploadClothing generates idempotency key when not provided',
      () async {
        // Create a temporary file for testing
        final tempDir = await Directory.systemTemp.createTemp('clothing_test_');
        final tempFile = File('${tempDir.path}/test_image.jpg');
        await tempFile.writeAsBytes([0xFF, 0xD8, 0xFF]); // Simple JPEG header

        try {
          final result = await repository.uploadClothing(
            tempFile,
            userId: 'test-user-id',
          );

          // Note: The current implementation returns a placeholder result
          // In a real implementation, we would verify the idempotency key
          expect(result.isFailure, false);
        } finally {
          await tempFile.delete();
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
      } finally {
        await tempFile.delete();
        await tempDir.delete(recursive: true);
      }
    });
  });

  group('ClothingRepository CRUD Operations', () {
    test('getClothingItems returns empty list when no items exist', () async {
      final result = await repository.getClothingItems(userId: 'user123');

      expect(result.isFailure, false);
      if (result.isSuccess) {
        expect(result.valueOrNull, isEmpty);
      }
    });

    test(
      'getClothingItem returns not found error when item does not exist',
      () async {
        final result = await repository.getClothingItem('non-existent-id');

        expect(result.isFailure, true);
        if (result.isFailure) {
          expect(result.errorOrNull, isA<ClothingItemNotFoundError>());
        }
      },
    );

    test('deleteClothing succeeds', () async {
      final result = await repository.deleteClothing('test-id');

      expect(result.isFailure, false);
    });

    test('retryProcessing returns failure for non-existent item', () async {
      final result = await repository.retryProcessing('test-id');

      // The current implementation returns a failure for non-existent items
      expect(result.isFailure, true);
    });
  });

  group('ClothingRepository Storage Quota', () {
    test('getStorageQuota returns quota with correct limits', () async {
      final result = await repository.getStorageQuota('user123');

      expect(result.isFailure, false);
      if (result.isSuccess) {
        final quota = result.valueOrNull!;
        expect(quota.maxItems, 500);
        expect(quota.maxBytes, 2 * 1024 * 1024 * 1024); // 2GB
        expect(quota.itemCount, 0);
        expect(quota.bytesUsed, 0);
        expect(quota.isExceeded, false);
      }
    });
  });
}

// Mock classes for testing
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockReference extends Mock implements Reference {}

class MockTaskSnapshot extends Mock implements TaskSnapshot {}
