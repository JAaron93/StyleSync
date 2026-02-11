// StyleSync Data Models
// This file contains all data model definitions for the application

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
}

enum AgeVerificationMethod {
  selfReported,
  thirdPartyVerified,
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
}

enum ItemProcessingState {
  uploading,
  processing,
  completed,
  processingFailed,
}

class ClothingTags {
  final ClothingCategory category;
  final List<String> colors;
  final List<Season> seasons;
  final Map<String, dynamic> additionalAttributes;
}

enum ClothingCategory {
  tops,
  bottoms,
  shoes,
  accessories,
  outerwear,
}

enum Season {
  spring,
  summer,
  fall,
  winter,
  allSeason,
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
}

class OutfitLayer {
  final LayerType type;
  final String clothingItemId;
  final int zIndex;
  final Map<String, dynamic>? positioning; // For canvas positioning
}

enum LayerType {
  base,
  mid,
  outer,
  accessories,
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
}

enum SecureStorageBackend {
  strongBox,        // Android 9+ StrongBox
  hardwareBacked,   // iOS Secure Enclave, Android Keystore
  software,         // Software-only fallback
}

class CloudBackupMetadata {
  final String userId;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final KDFMetadata kdfMetadata;
  final String encryptedData;
  final String nonce;
}

class KDFMetadata {
  final KDFAlgorithm algorithm;
  final String salt; // Base64 encoded
  final Map<String, dynamic> params;
}

enum KDFAlgorithm {
  argon2id,
  pbkdf2,
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
}

class UsageHistoryEntry {
  final String id;
  final String userId;
  final QuotaEventType eventType;
  final DateTime timestamp;
  final int requestCount;
  final Map<String, dynamic> metadata;
}

enum QuotaEventType {
  tryOnGenerated,
  quotaReset,
  warning80Percent,
  limitReached,
  apiKeyUpdated,
}

class StorageQuota {
  final int itemCount;
  final int maxItems; // 500
  final int bytesUsed;
  final int maxBytes; // 2GB
  final bool isExceeded;
}

// ============================================================================
// Virtual Try-On Models
// ============================================================================

class GeneratedImage {
  final String id;
  final String userId;
  final String imageUrl;
  final String modelUsed;
  final GenerationMode mode;
  final DateTime generatedAt;
  final String clothingItemId;
  final Map<String, dynamic> metadata;
}

class GenerationMode {
  final String name;
  final String primaryModelId;
  final List<String> fallbackModelIds;
  
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
}

class NetworkError extends AppError {
  NetworkError(super.message, {super.code, super.originalError});
}

class APIError extends AppError {
  final int? statusCode;
  APIError(super.message, {this.statusCode, super.code, super.originalError});
}

class QuotaExceededError extends APIError {
  final DateTime resetTime;
  QuotaExceededError(super.message, this.resetTime, {super.statusCode, super.code});
}

class ValidationError extends AppError {
  final Map<String, String> fieldErrors;
  ValidationError(super.message, this.fieldErrors, {super.code});
}

class StorageQuotaError extends AppError {
  final StorageQuota currentQuota;
  StorageQuotaError(super.message, this.currentQuota, {super.code});
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
