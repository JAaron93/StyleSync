import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'models/clothing_error.dart';
import 'models/clothing_item.dart';

/// Result type for clothing operations.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    Failure<T>() => null,
  };
  ClothingError? get errorOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(:final error) => error,
  };
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
  @override
  String toString() => 'Success($value)';
}

class Failure<T> extends Result<T> {
  final ClothingError error;
  const Failure(this.error);
  @override
  String toString() => 'Failure($error)';
}

/// Repository for managing clothing items in the digital closet.
abstract class ClothingRepository {
  /// Uploads a clothing item.
  ///
  /// [image] - The original image file to upload.
  /// [idempotencyKey] - Optional idempotency key for deduplication.
  /// [metadata] - Optional additional metadata to store.
  ///
  /// Returns [Success] with the created [ClothingItem] if successful.
  /// Returns [Failure] with [ClothingError] if the operation fails.
  Future<Result<ClothingItem>> uploadClothing(
    File image, {
    required String userId,
    String? idempotencyKey,
    Map<String, dynamic>? metadata,
  });

  /// Retrieves all clothing items for a user.
  ///
  /// [userId] - The user ID to retrieve items for.
  /// [category] - Optional category filter.
  /// [limit] - Maximum number of items to return.
  /// [offset] - Number of items to skip for pagination.
  Future<Result<List<ClothingItem>>> getClothingItems({
    required String userId,
    String? category,
    int limit = 50,
    int offset = 0,
  });

  /// Retrieves a single clothing item by ID.
  ///
  /// [itemId] - The ID of the item to retrieve.
  Future<Result<ClothingItem>> getClothingItem(String itemId);

  /// Updates a clothing item.
  ///
  /// [itemId] - The ID of the item to update.
  /// [updates] - The fields to update.
  Future<Result<ClothingItem>> updateClothing(
    String itemId,
    ClothingItem updates,
  );

  /// Deletes a clothing item.
  ///
  /// [itemId] - The ID of the item to delete.
  /// [deleteImage] - Whether to also delete the image from Firebase Storage.
  Future<Result<void>> deleteClothing(String itemId, {bool deleteImage = true});

  /// Gets the current storage quota for a user.
  ///
  /// [userId] - The user ID to check quota for.
  Future<Result<StorageQuota>> getStorageQuota(String userId);

  /// Retries processing for a failed item.
  ///
  /// [itemId] - The ID of the item to retry.
  Future<Result<ClothingItem>> retryProcessing(String itemId);
}

/// Default implementation of [ClothingRepository].
///
/// Uses Firebase Firestore for metadata storage and Firebase Storage
/// for image storage.
class ClothingRepositoryImpl implements ClothingRepository {
  /// The UUID generator for creating IDs.
  final Uuid _uuid;

  /// The Firestore instance for metadata storage.
  final FirebaseFirestore _firestore;

  /// The Storage instance for image storage.
  final FirebaseStorage _storage;

  /// Creates a new [ClothingRepositoryImpl] instance.
  ///
  /// Dependencies can be injected for testing.
  ClothingRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _uuid = uuid ?? const Uuid();

  /// Checks if the given error is a network-related error.
  bool _isNetworkError(Object error) {
    if (error is SocketException) {
      return true;
    }
    if (error is HttpException) {
      return true;
    }
    if (error is FirebaseException) {
      const networkErrorCodes = {'network-request-failed', 'unavailable'};
      return networkErrorCodes.contains(error.code);
    }
    return false;
  }

  @override
  Future<Result<ClothingItem>> uploadClothing(
    File image, {
    required String userId,
    String? idempotencyKey,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validate image file
      if (!await image.exists()) {
        return Failure(ClothingValidationError('Image file does not exist'));
      }

      // Generate idempotency key if not provided
      final finalIdempotencyKey = idempotencyKey ?? _uuid.v4();

      // TODO: Implement actual image processing (background removal, tagging)
      // For now, we'll simulate the upload process

      // Create a placeholder clothing item
      // In a real implementation, this would process the image and generate
      // processed and thumbnail versions
      // NOTE: This placeholder branch is only for debug/test builds. Production
      // builds should never use these example.com URLs.
      final clothingItem = () {
        // Prevent placeholder from being used in production builds
        if (!kDebugMode) {
          throw UnimplementedError(
            'ClothingItem upload is not yet implemented. '
            'Image processing, storage upload, and Firestore persistence '
            'are required before production use.',
          );
        }
        return ClothingItem.create(
          userId: userId,
          imageUrl: 'https://example.com/image.jpg',
          processedImageUrl: 'https://example.com/processed.jpg',
          thumbnailUrl: 'https://example.com/thumbnail.jpg',
          category: 'tops',
          colors: ['blue', 'white'],
          seasons: ['spring', 'summer', 'all-season'],
          idempotencyKey: finalIdempotencyKey,
        );
      }();

      // Upload image to Firebase Storage
      final itemId = clothingItem.id;
      final imageRef = _storage.ref().child('users/$userId/clothing/$itemId/original.jpg');
      await imageRef.putFile(image);
      final downloadUrl = await imageRef.getDownloadURL();

      final updatedItem = clothingItem.copyWith(imageUrl: downloadUrl);

      // Store metadata in Firestore
      await _firestore.collection('clothing_items').doc(itemId).set(
        updatedItem.toJson(),
      );

      return Success(updatedItem);
    } on FirebaseException catch (e) {
      return Failure(
        FirebaseError('Firebase error: ${e.message}', originalError: e),
      );
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(
          NetworkError(
            'Network error during upload: ${e.toString()}',
            originalError: e,
          ),
        );
      }
      return Failure(
        ProcessingError(
          'Failed to upload clothing: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<Result<List<ClothingItem>>> getClothingItems({
    required String userId,
    String? category,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Query Firestore for clothing items
      var query = _firestore
          .collection('clothing_items')
          .where('userId', isEqualTo: userId);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query
          .orderBy('uploadedAt', descending: true)
          .limit(limit)
          // .offset(offset) // Firebase doesn't support easy offset pagination without cursors
          .get();

      final items = snapshot.docs
          .map((doc) => ClothingItem.fromJson(doc.data()))
          .toList();

      return Success(items);
    } on FirebaseException catch (e) {
      return Failure(
        FirebaseError('Firebase error: ${e.message}', originalError: e),
      );
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(
          NetworkError(
            'Network error during fetch: ${e.toString()}',
            originalError: e,
          ),
        );
      }
      return Failure(
        ProcessingError(
          'Failed to fetch clothing items: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<Result<ClothingItem>> getClothingItem(String itemId) async {
    try {
      // Query Firestore for a single clothing item
      final doc = await _firestore.collection('clothing_items').doc(itemId).get();

      if (!doc.exists) {
        return const Failure(ClothingItemNotFoundError());
      }

      final item = ClothingItem.fromJson(doc.data()!);
      return Success(item);
    } on FirebaseException catch (e) {
      return Failure(
        FirebaseError('Firebase error: ${e.message}', originalError: e),
      );
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(
          NetworkError(
            'Network error during fetch: ${e.toString()}',
            originalError: e,
          ),
        );
      }
      return Failure(
        ProcessingError(
          'Failed to fetch clothing item: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<Result<ClothingItem>> updateClothing(
    String itemId,
    ClothingItem updates,
  ) async {
    try {
      // Update Firestore document
      await _firestore.collection('clothing_items').doc(itemId).update(
        updates.toJson(),
      );

      // Refetch to get server-side mutations like serverTimestamp
      final doc = await _firestore.collection('clothing_items').doc(itemId).get();
      final updatedItem = ClothingItem.fromJson(doc.data()!);

      return Success(updatedItem);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return const Failure(ClothingItemNotFoundError());
      }
      return Failure(
        FirebaseError('Firebase error: ${e.message}', originalError: e),
      );
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(
          NetworkError(
            'Network error during update: ${e.toString()}',
            originalError: e,
          ),
        );
      }
      return Failure(
        ProcessingError(
          'Failed to update clothing item: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteClothing(
    String itemId, {
    bool deleteImage = true,
  }) async {
    try {
      // Get image URL before deleting document if we need to delete the image
      String? imageUrl;
      if (deleteImage) {
        final itemResult = await getClothingItem(itemId);
        if (itemResult.isSuccess) {
          imageUrl = itemResult.valueOrNull?.imageUrl;
        }
      }

      // Delete from Firestore
      await _firestore.collection('clothing_items').doc(itemId).delete();

      // Delete from Firebase Storage if requested
      if (deleteImage && imageUrl != null) {
        final imageRef = _storage.refFromURL(imageUrl);
        await imageRef.delete();
      }

      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(
        FirebaseError('Firebase error: ${e.message}', originalError: e),
      );
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(
          NetworkError(
            'Network error during deletion: ${e.toString()}',
            originalError: e,
          ),
        );
      }
      return Failure(
        ProcessingError(
          'Failed to delete clothing item: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<Result<StorageQuota>> getStorageQuota(String userId) async {
    try {
      // Query Firestore to count items and calculate total size
      final itemsSnapshot = await _firestore
          .collection('clothing_items')
          .where('userId', isEqualTo: userId)
          .get();

      final itemCount = itemsSnapshot.size;
      final totalBytes = itemsSnapshot.docs.fold<int>(0, (sum, doc) {
        // Estimate size from image URLs (in a real implementation, store actual sizes)
        return sum + 1024 * 1024; // Assume 1MB per image for estimation
      });

      final quota = StorageQuota(
        itemCount: itemCount,
        maxItems: 500,
        bytesUsed: totalBytes,
        maxBytes: 2 * 1024 * 1024 * 1024, // 2GB
      );
      return Success(quota);
    } on FirebaseException catch (e) {
      return Failure(
        FirebaseError('Firebase error: ${e.message}', originalError: e),
      );
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(
          NetworkError(
            'Network error during quota check: ${e.toString()}',
            originalError: e,
          ),
        );
      }
      return Failure(
        FirebaseError(
          'Failed to check storage quota: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<Result<ClothingItem>> retryProcessing(String itemId) async {
    // STUB: Real retry logic with exponential backoff is pending Firestore
    // integration (see uploadClothing TODO).
    //
    // This method delegates to getClothingItem to locate the item before
    // updating its processingState. Because getClothingItem is also a stub
    // that always returns Failure(ClothingItemNotFoundError()), this method
    // will always propagate that failure until persistence is wired up.
    //
    // TODO: Replace with real implementation:
    //   1. Fetch item from Firestore (getClothingItem).
    //   2. Increment retryCount and set processingState = processing.
    //   3. Persist updated state via _firestore.collection(...).doc(itemId).update(...).
    //   4. Return Success(updatedItem).
    try {
      final item = await getClothingItem(itemId);
      if (item.isFailure) {
        // Propagate the failure — most likely ClothingItemNotFoundError until
        // getClothingItem is backed by real Firestore queries.
        return item;
      }

      // Unreachable until getClothingItem is implemented; kept so the future
      // real implementation has a clear skeleton to fill in.
      final currentItem = item.valueOrNull!;
      final updatedItem = currentItem.copyWith(
        processingState: ItemProcessingState.processing,
        retryCount: currentItem.retryCount + 1,
      );

      // TODO: Persist updated state to Firestore.
      // await _firestore.collection('clothing_items').doc(itemId).update({
      //   'processingState': 'processing',
      //   'retryCount': updatedItem.retryCount,
      // });

      return Success(updatedItem);
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(
          NetworkError(
            'Network error during retry: ${e.toString()}',
            originalError: e,
          ),
        );
      }
      return Failure(
        ProcessingError(
          'Failed to retry processing: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

/// Provider for [ClothingRepository].
///
/// Creates a [ClothingRepositoryImpl] instance with Firebase dependencies
/// explicitly injected. This allows for easier testing by substituting
/// mock implementations.
final clothingRepositoryProvider = Provider<ClothingRepository>((ref) {
  return ClothingRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
    uuid: const Uuid(),
  );
});
