// StyleSync Data Models
// This file contains all data model definitions for the application

import 'package:logging/logging.dart';

/// Logger for data model parsing operations.
final Logger _logger = Logger('DataModels');

// ============================================================================
// User Models
// ============================================================================

class UserProfile {
  final String userId;
  final String email;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool onboardingComplete;
  final bool faceDetectionConsentGranted;
  final bool biometricConsentGranted;
  final bool is18PlusVerified;
  final AgeVerificationMethod verificationMethod;

  const UserProfile({
    required this.userId,
    required this.email,
    required this.createdAt,
    this.lastLoginAt,
    required this.onboardingComplete,
    required this.faceDetectionConsentGranted,
    required this.biometricConsentGranted,
    required this.is18PlusVerified,
    required this.verificationMethod,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String) 
          : null,
      onboardingComplete: json['onboardingComplete'] as bool,
      faceDetectionConsentGranted: json['faceDetectionConsentGranted'] as bool,
      biometricConsentGranted: json['biometricConsentGranted'] as bool,
      is18PlusVerified: json['is18PlusVerified'] as bool,
      verificationMethod: _parseAgeVerificationMethod(json['verificationMethod'] as String),
    );
  }

  static AgeVerificationMethod _parseAgeVerificationMethod(String value) {
    try {
      return AgeVerificationMethod.values.byName(value);
    } catch (e) {
      _logger.warning('Unknown AgeVerificationMethod value: $value', e);
      return AgeVerificationMethod.unknown;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'onboardingComplete': onboardingComplete,
      'faceDetectionConsentGranted': faceDetectionConsentGranted,
      'biometricConsentGranted': biometricConsentGranted,
      'is18PlusVerified': is18PlusVerified,
      'verificationMethod': verificationMethod.toString().split('.').last,
    };
  }
}

enum AgeVerificationMethod {
  selfReported,
  thirdPartyVerified,
  unknown,
}

// ============================================================================
// Clothing Models
// ============================================================================

class ClothingItem {
  final String id;
  final String userId;
  final String imageUrl;
  final String thumbnailUrl;
  final String? processedImageUrl;
  final ClothingTags tags;
  final DateTime uploadedAt;
  final DateTime? updatedAt;
  final ItemProcessingState processingState;
  final String? failureReason;
  final int retryCount;
  final String idempotencyKey;
  final Map<String, dynamic> metadata;

  const ClothingItem({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.processedImageUrl,
    required this.tags,
    required this.uploadedAt,
    this.updatedAt,
    required this.processingState,
    this.failureReason,
    required this.retryCount,
    required this.idempotencyKey,
    required this.metadata,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      processedImageUrl: json['processedImageUrl'] as String?,
      tags: ClothingTags.fromJson(json['tags'] as Map<String, dynamic>),
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      processingState: _parseItemProcessingState(json['processingState'] as String),
      failureReason: json['failureReason'] as String?,
      retryCount: json['retryCount'] as int,
      idempotencyKey: json['idempotencyKey'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'processedImageUrl': processedImageUrl,
      'tags': tags.toJson(),
      'uploadedAt': uploadedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'processingState': processingState.toString().split('.').last,
      'failureReason': failureReason,
      'retryCount': retryCount,
      'idempotencyKey': idempotencyKey,
      'metadata': metadata,
    };
  }

  static ItemProcessingState _parseItemProcessingState(String value) {
    try {
      return ItemProcessingState.values.byName(value);
    } catch (e) {
      _logger.warning('Unknown ItemProcessingState value: $value', e);
      return ItemProcessingState.unknown;
    }
  }
}

enum ItemProcessingState {
  uploading,
  processing,
  completed,
  processingFailed,
  unknown,
}

class ClothingTags {
  final ClothingCategory category;
  final List<String> colors;
  final List<Season> seasons;
  final Map<String, dynamic> additionalAttributes;

  const ClothingTags({
    required this.category,
    required this.colors,
    required this.seasons,
    required this.additionalAttributes,
  });

  factory ClothingTags.fromJson(Map<String, dynamic> json) {
    return ClothingTags(
      category: _parseClothingCategory(json['category'] as String),
      colors: List<String>.from(json['colors'] as List),
      seasons: (json['seasons'] as List)
          .map((s) => _parseSeason(s as String))
          .toList(),
      additionalAttributes: json['additionalAttributes'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.toString().split('.').last,
      'colors': colors,
      'seasons': seasons.map((s) => s.toString().split('.').last).toList(),
      'additionalAttributes': additionalAttributes,
    };
  }

  static ClothingCategory _parseClothingCategory(String value) {
    try {
      return ClothingCategory.values.byName(value);
    } catch (e) {
      _logger.warning('Unknown ClothingCategory value: $value', e);
      return ClothingCategory.unknown;
    }
  }

  static Season _parseSeason(String value) {
    try {
      return Season.values.byName(value);
    } catch (e) {
      _logger.warning('Unknown Season value: $value', e);
      return Season.unknown;
    }
  }
}

enum ClothingCategory {
  tops,
  bottoms,
  shoes,
  accessories,
  outerwear,
  unknown,
}

enum Season {
  spring,
  summer,
  fall,
  winter,
  allSeason,
  unknown,
}

// ============================================================================
// Outfit Models
// ============================================================================

class Outfit {
  final String id;
  final String userId;
  final String name;
  final List<OutfitLayer> layers;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Outfit({
    required this.id,
    required this.userId,
    required this.name,
    required this.layers,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      layers: (json['layers'] as List)
          .map((l) => OutfitLayer.fromJson(l as Map<String, dynamic>))
          .toList(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'layers': layers.map((l) => l.toJson()).toList(),
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class OutfitLayer {
  final String id;
  final String name;
  final LayerType type;
  final String clothingItemId;
  final int index;
  final bool isVisible;
  final double opacity;
  final String? assetReference;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic>? positioning; // For canvas positioning

  const OutfitLayer({
    required this.id,
    required this.name,
    required this.type,
    required this.clothingItemId,
    required this.index,
    required this.isVisible,
    required this.opacity,
    this.assetReference,
    required this.metadata,
    this.positioning,
  });

  factory OutfitLayer.fromJson(Map<String, dynamic> json) {
    return OutfitLayer(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _parseLayerType(json['type'] as String),
      clothingItemId: json['clothingItemId'] as String,
      index: json['index'] as int,
      isVisible: json['isVisible'] as bool,
      opacity: (json['opacity'] as num).toDouble(),
      assetReference: json['assetReference'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      positioning: json['positioning'] != null ? Map<String, dynamic>.from(json['positioning'] as Map) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'clothingItemId': clothingItemId,
      'index': index,
      'isVisible': isVisible,
      'opacity': opacity,
      'assetReference': assetReference,
      'metadata': metadata,
      'positioning': positioning,
    };
  }

  static LayerType _parseLayerType(String value) {
    try {
      return LayerType.values.byName(value);
    } catch (e) {
      _logger.warning('Unknown LayerType value: $value', e);
      return LayerType.unknown;
    }
  }
}

enum LayerType {
  base,
  mid,
  outer,
  accessories,
  unknown,
}

// ============================================================================
// API Key & Storage Models
// ============================================================================
class APIKeyConfig {
  final String apiKey;
  final String projectId;
  final DateTime createdAt;
  final DateTime lastValidated;
  final bool cloudBackupEnabled;
  final SecureStorageBackend storageBackend;

  const APIKeyConfig({
    required this.apiKey,
    required this.projectId,
    required this.createdAt,
    required this.lastValidated,
    required this.cloudBackupEnabled,
    required this.storageBackend,
  });

  @override
  String toString() => 'APIKeyConfig(projectId: $projectId, cloudBackupEnabled: $cloudBackupEnabled)';

  factory APIKeyConfig.fromJson(Map<String, dynamic> json) {
    return APIKeyConfig(
      apiKey: json['apiKey'] as String,
      projectId: json['projectId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastValidated: DateTime.parse(json['lastValidated'] as String),
      cloudBackupEnabled: json['cloudBackupEnabled'] as bool,
      storageBackend: _parseSecureStorageBackend(json['storageBackend'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'createdAt': createdAt.toIso8601String(),
      'lastValidated': lastValidated.toIso8601String(),
      'cloudBackupEnabled': cloudBackupEnabled,
      'storageBackend': storageBackend.toString().split('.').last,
    };
  }

  /// For secure storage only - includes sensitive data
  Map<String, dynamic> toSecureJson() {
    return {
      ...toJson(),
      'apiKey': apiKey,
    };
  }

  static SecureStorageBackend _parseSecureStorageBackend(String value) {
    try {
      return SecureStorageBackend.values.byName(value);
    } catch (e) {
      _logger.warning('Unknown SecureStorageBackend value: $value', e);
      return SecureStorageBackend.unknown;
    }
  }
}

enum SecureStorageBackend {
  strongBox,        // Android 9+ StrongBox
  hardwareBacked,   // iOS Secure Enclave, Android Keystore
  software,         // Software-only fallback
  unknown,
}

class CloudBackupMetadata {
  final String userId;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final KDFMetadata kdfMetadata;
  final String encryptedData;
  final String nonce;

  const CloudBackupMetadata({
    required this.userId,
    required this.createdAt,
    required this.lastUpdated,
    required this.kdfMetadata,
    required this.encryptedData,
    required this.nonce,
  });

  factory CloudBackupMetadata.fromJson(Map<String, dynamic> json) {
    return CloudBackupMetadata(
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      kdfMetadata: KDFMetadata.fromJson(json['kdfMetadata'] as Map<String, dynamic>),
      encryptedData: json['encryptedData'] as String,
      nonce: json['nonce'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'kdfMetadata': kdfMetadata.toJson(),
      'encryptedData': encryptedData,
      'nonce': nonce,
    };
  }
}

class KDFMetadata {
  final KDFAlgorithm algorithm;
  final String salt; // Base64 encoded
  final Map<String, dynamic> params;

  const KDFMetadata({
    required this.algorithm,
    required this.salt,
    required this.params,
  });

  factory KDFMetadata.fromJson(Map<String, dynamic> json) {
    return KDFMetadata(
      algorithm: _parseKDFAlgorithm(json['algorithm'] as String),
      salt: json['salt'] as String,
      params: json['params'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'algorithm': algorithm.toString().split('.').last,
      'salt': salt,
      'params': params,
    };
  }

  static KDFAlgorithm _parseKDFAlgorithm(String value) {
    try {
      return KDFAlgorithm.values.byName(value);
    } catch (e) {
      _logger.warning('Unknown KDFAlgorithm value: $value', e);
      return KDFAlgorithm.unknown;
    }
  }
}

enum KDFAlgorithm {
  argon2id,
  pbkdf2,
  unknown,
}

// ============================================================================
// Quota & Usage Models
// ============================================================================

class QuotaStatus {
  final int usedToday;
  final int estimatedRemaining;
  final DateTime resetTimeUTC;
  final bool isExceeded;
  final double usagePercentage;
  final String quotaTrackingId; // Random UUID, not linked to API key

  const QuotaStatus({
    required this.usedToday,
    required this.estimatedRemaining,
    required this.resetTimeUTC,
    required this.isExceeded,
    required this.usagePercentage,
    required this.quotaTrackingId,
  });

  factory QuotaStatus.fromJson(Map<String, dynamic> json) {
    return QuotaStatus(
      usedToday: json['usedToday'] as int,
      estimatedRemaining: json['estimatedRemaining'] as int,
      resetTimeUTC: DateTime.parse(json['resetTimeUTC'] as String),
      isExceeded: json['isExceeded'] as bool,
      usagePercentage: (json['usagePercentage'] as num).toDouble(),
      quotaTrackingId: json['quotaTrackingId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usedToday': usedToday,
      'estimatedRemaining': estimatedRemaining,
      'resetTimeUTC': resetTimeUTC.toIso8601String(),
      'isExceeded': isExceeded,
      'usagePercentage': usagePercentage,
      'quotaTrackingId': quotaTrackingId,
    };
  }
}

class UsageHistoryEntry {
  final String id;
  final String userId;
  final QuotaEventType eventType;
  final DateTime timestamp;
  final int requestCount;
  final Map<String, dynamic> metadata;

  const UsageHistoryEntry({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.timestamp,
    required this.requestCount,
    required this.metadata,
  });

  factory UsageHistoryEntry.fromJson(Map<String, dynamic> json) {
    return UsageHistoryEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      eventType: _parseQuotaEventType(json['eventType'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      requestCount: json['requestCount'] as int,
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventType': eventType.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'requestCount': requestCount,
      'metadata': metadata,
    };
  }

  static QuotaEventType _parseQuotaEventType(String value) {
    try {
      return QuotaEventType.values.byName(value);
    } catch (e) {
      _logger.warning('Unknown QuotaEventType value: $value', e);
      return QuotaEventType.unknown;
    }
  }
}

enum QuotaEventType {
  tryOnGenerated,
  quotaReset,
  warning80Percent,
  limitReached,
  apiKeyUpdated,
  unknown,
}

class StorageQuota {
  final int itemCount;
  final int maxItems; // 500
  final int bytesUsed;
  final int maxBytes; // 2GB
  final bool isExceeded;

  const StorageQuota({
    required this.itemCount,
    required this.maxItems,
    required this.bytesUsed,
    required this.maxBytes,
    required this.isExceeded,
  });

  factory StorageQuota.fromJson(Map<String, dynamic> json) {
    return StorageQuota(
      itemCount: json['itemCount'] as int,
      maxItems: json['maxItems'] as int,
      bytesUsed: json['bytesUsed'] as int,
      maxBytes: json['maxBytes'] as int,
      isExceeded: json['isExceeded'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCount': itemCount,
      'maxItems': maxItems,
      'bytesUsed': bytesUsed,
      'maxBytes': maxBytes,
      'isExceeded': isExceeded,
    };
  }
}

// ============================================================================
// Virtual Try-On Models
// ============================================================================

class GeneratedImage {
  final String id;
  final String userId;
  final String imageUrl;
  final String modelUsed;
  final String modeName; // References GenerationMode.name
  final DateTime generatedAt;
  final String clothingItemId;
  final Map<String, dynamic> metadata;

  const GeneratedImage({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.modelUsed,
    required this.modeName,
    required this.generatedAt,
    required this.clothingItemId,
    required this.metadata,
  });

  factory GeneratedImage.fromJson(Map<String, dynamic> json) {
    return GeneratedImage(
      id: json['id'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      modelUsed: json['modelUsed'] as String,
      modeName: json['modeName'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      clothingItemId: json['clothingItemId'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'modelUsed': modelUsed,
      'modeName': modeName,
      'generatedAt': generatedAt.toIso8601String(),
      'clothingItemId': clothingItemId,
      'metadata': metadata,
    };
  }
}

class GenerationMode {
  final String name;
  final String primaryModelId;
  final List<String> fallbackModelIds;

  const GenerationMode({
    required this.name,
    required this.primaryModelId,
    required this.fallbackModelIds,
  });
  
  static const quality = GenerationMode(
    name: 'quality',
    primaryModelId: 'gemini-3-pro-image-preview',
    fallbackModelIds: ['gemini-2.5-flash-image'],
  );
  
  static const speed = GenerationMode(
    name: 'speed',
    primaryModelId: 'gemini-2.5-flash-image',
    fallbackModelIds: ['gemini-3-pro-image-preview'],
  );
  
  static const tryOn = GenerationMode(
    name: 'tryOn',
    primaryModelId: 'virtual-try-on-preview-08-04',
    fallbackModelIds: ['gemini-3-pro-image-preview', 'gemini-2.5-flash-image'],
  );
}

// ============================================================================
// Error Models
// ============================================================================

sealed class AppError {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
  });
}

class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.originalError,
  });
}

class APIError extends AppError {
  final int? statusCode;
  const APIError({
    required super.message,
    this.statusCode,
    super.code,
    super.originalError,
  });
}

class QuotaExceededError extends APIError {
  final DateTime resetTime;
  const QuotaExceededError({
    required super.message,
    required this.resetTime,
    super.statusCode,
    super.code,
  });
}

class ValidationError extends AppError {
  final Map<String, String> fieldErrors;
  const ValidationError({
    required super.message,
    required this.fieldErrors,
    super.code,
  });
}

class StorageQuotaError extends AppError {
  final StorageQuota currentQuota;
  const StorageQuotaError({
    required super.message,
    required this.currentQuota,
    super.code,
  });
}

// ============================================================================
// Result Type
// ============================================================================

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}
