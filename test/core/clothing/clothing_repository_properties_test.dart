import 'package:flutter_test/flutter_test.dart';

import 'package:stylesync/core/clothing/models/clothing_error.dart';
import 'package:stylesync/core/clothing/models/clothing_item.dart';

void main() {
  group('Property 7: Storage Quota Enforcement', () {
    // Property: Storage quota is correctly enforced when uploading items
    test('storage quota is exceeded when itemCount >= maxItems', () {
      final quota = StorageQuota(
        itemCount: 500,
        maxItems: 500,
        bytesUsed: 0,
        maxBytes: 2 * 1024 * 1024 * 1024,
      );
      expect(quota.isExceeded, true,
          reason: 'Quota should be exceeded when itemCount >= maxItems');
    });

    test('storage quota is not exceeded when itemCount < maxItems', () {
      final quota = StorageQuota(
        itemCount: 499,
        maxItems: 500,
        bytesUsed: 0,
        maxBytes: 2 * 1024 * 1024 * 1024,
      );
      expect(quota.isExceeded, false,
          reason: 'Quota should not be exceeded when itemCount < maxItems');
    });

    test('storage quota is exceeded when bytesUsed >= maxBytes', () {
      final quota = StorageQuota(
        itemCount: 0,
        maxItems: 500,
        bytesUsed: 2 * 1024 * 1024 * 1024,
        maxBytes: 2 * 1024 * 1024 * 1024,
      );
      expect(quota.isExceeded, true,
          reason: 'Quota should be exceeded when bytesUsed >= maxBytes');
    });

    test('storage quota is not exceeded when within both limits', () {
      final quota = StorageQuota(
        itemCount: 499,
        maxItems: 500,
        bytesUsed: 2 * 1024 * 1024 * 1024 - 1,
        maxBytes: 2 * 1024 * 1024 * 1024,
      );
      expect(quota.isExceeded, false,
          reason: 'Quota should not be exceeded when within limits');
    });

    // Property: Storage quota copyWith preserves all fields
    test('storage quota copyWith updates itemCount correctly', () {
      final quota = StorageQuota(
        itemCount: 100,
        maxItems: 500,
        bytesUsed: 100 * 1024 * 1024,
        maxBytes: 2 * 1024 * 1024 * 1024,
      );
      final updated = quota.copyWith(itemCount: 200);
      expect(updated.itemCount, 200);
      expect(updated.maxItems, 500);
      expect(updated.bytesUsed, 100 * 1024 * 1024);
      expect(updated.maxBytes, 2 * 1024 * 1024 * 1024);
    });

    test('storage quota copyWith updates bytesUsed correctly', () {
      final quota = StorageQuota(
        itemCount: 100,
        maxItems: 500,
        bytesUsed: 100 * 1024 * 1024,
        maxBytes: 2 * 1024 * 1024 * 1024,
      );
      final updated = quota.copyWith(bytesUsed: 200 * 1024 * 1024);
      expect(updated.itemCount, 100);
      expect(updated.bytesUsed, 200 * 1024 * 1024);
    });

    // Property: Storage quota JSON serialization round-trip
    test('storage quota JSON serialization round-trip', () {
      final quota = StorageQuota(
        itemCount: 150,
        maxItems: 500,
        bytesUsed: 150 * 1024 * 1024,
        maxBytes: 2 * 1024 * 1024 * 1024,
      );
      final json = quota.toJson();
      final deserialized = StorageQuota.fromJson(json);

      expect(deserialized.itemCount, quota.itemCount);
      expect(deserialized.maxItems, quota.maxItems);
      expect(deserialized.bytesUsed, quota.bytesUsed);
      expect(deserialized.maxBytes, quota.maxBytes);
      expect(deserialized.isExceeded, quota.isExceeded);
    });
  });

  group('Property 25: Clothing Item CRUD Consistency', () {
    // Property: Clothing item can be created and retrieved
    test('clothing item JSON serialization round-trip', () {
      final item = ClothingItem.create(
        userId: 'user123',
        imageUrl: 'https://example.com/image.jpg',
        processedImageUrl: 'https://example.com/processed.jpg',
        thumbnailUrl: 'https://example.com/thumbnail.jpg',
        category: 'tops',
        colors: ['blue', 'white'],
        seasons: ['spring', 'summer'],
      );

      final json = item.toJson();
      final deserialized = ClothingItem.fromJson(json);

      expect(deserialized.id, item.id);
      expect(deserialized.userId, item.userId);
      expect(deserialized.imageUrl, item.imageUrl);
      expect(deserialized.processedImageUrl, item.processedImageUrl);
      expect(deserialized.thumbnailUrl, item.thumbnailUrl);
      expect(deserialized.category, item.category);
      expect(deserialized.colors, item.colors);
      expect(deserialized.seasons, item.seasons);
      expect(deserialized.processingState, item.processingState);
      expect(deserialized.idempotencyKey, item.idempotencyKey);
    });

    // Property: Clothing item copyWith preserves all fields
    test('clothing item copyWith updates fields correctly', () {
      final item = ClothingItem.create(
        userId: 'user123',
        imageUrl: 'https://example.com/image.jpg',
        processedImageUrl: 'https://example.com/processed.jpg',
        thumbnailUrl: 'https://example.com/thumbnail.jpg',
        category: 'tops',
        colors: ['blue', 'white'],
        seasons: ['spring', 'summer'],
      );

      final updated = item.copyWith(
        category: 'bottoms',
        colors: ['red', 'black'],
      );

      expect(updated.category, 'bottoms');
      expect(updated.colors, ['red', 'black']);
      expect(updated.userId, item.userId);
      expect(updated.imageUrl, item.imageUrl);
    });

    // Property: Clothing item equality works correctly
    test('clothing items with same data are equal', () {
      final now = DateTime.now().toUtc();
      final item1 = ClothingItem(
        id: 'fixed-id-123',
        userId: 'user123',
        imageUrl: 'https://example.com/image.jpg',
        processedImageUrl: 'https://example.com/processed.jpg',
        thumbnailUrl: 'https://example.com/thumbnail.jpg',
        category: 'tops',
        colors: ['blue', 'white'],
        seasons: ['spring', 'summer'],
        uploadedAt: now,
        updatedAt: now,
        processingState: ItemProcessingState.completed,
        idempotencyKey: 'idem-key-123',
      );

      final item2 = ClothingItem(
        id: 'fixed-id-123',
        userId: 'user123',
        imageUrl: 'https://example.com/image.jpg',
        processedImageUrl: 'https://example.com/processed.jpg',
        thumbnailUrl: 'https://example.com/thumbnail.jpg',
        category: 'tops',
        colors: ['blue', 'white'],
        seasons: ['spring', 'summer'],
        uploadedAt: now,
        updatedAt: now,
        processingState: ItemProcessingState.completed,
        idempotencyKey: 'idem-key-123',
      );

      expect(item1, item2);
    });

    test('clothing items with different data are not equal', () {
      final item1 = ClothingItem.create(
        userId: 'user123',
        imageUrl: 'https://example.com/image.jpg',
        processedImageUrl: 'https://example.com/processed.jpg',
        thumbnailUrl: 'https://example.com/thumbnail.jpg',
        category: 'tops',
        colors: ['blue', 'white'],
        seasons: ['spring', 'summer'],
      );

      final item2 = item1.copyWith(category: 'bottoms');

      expect(item1 != item2, true);
    });
  });
}
