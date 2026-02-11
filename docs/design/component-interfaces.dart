// StyleSync Component Interfaces
// This file defines the interfaces for all major components and services

// ============================================================================
// Repository Interfaces
// ============================================================================

abstract class ClothingRepository {
  /// Upload a clothing item with idempotency support
  Future<Result<ClothingItem>> uploadClothing(
    File image, {
    Map<String, dynamic>? metadata,
    String? idempotencyKey,
  });
  
  /// Get all clothing items for the current user
  Future<Result<List<ClothingItem>>> getClothingItems({
    ClothingCategory? category,
    Season? season,
  });
  
  /// Get a single clothing item by ID
  Future<Result<ClothingItem>> getClothingItem(String itemId);
  
  /// Update clothing item metadata
  Future<Result<ClothingItem>> updateClothing(
    String itemId,
    Map<String, dynamic> updates,
  );
  
  /// Delete a clothing item
  Future<Result<void>> deleteClothing(String itemId);
  
  /// Retry failed processing for an item
  Future<Result<ClothingItem>> retryProcessing(String itemId);
  
  /// Get current storage quota status
  Future<Result<StorageQuota>> getStorageQuota();
}

abstract class OutfitRepository {
  /// Save a new outfit
  Future<Result<Outfit>> saveOutfit(Outfit outfit);
  
  /// Get all outfits for the current user
  Future<Result<List<Outfit>>> getOutfits();
  
  /// Get a single outfit by ID
  Future<Result<Outfit>> getOutfit(String outfitId);
  
  /// Update an existing outfit
  Future<Result<Outfit>> updateOutfit(String outfitId, Outfit outfit);
  
  /// Delete an outfit
  Future<Result<void>> deleteOutfit(String outfitId);
}

abstract class UserRepository {
  /// Get current user profile
  Future<Result<UserProfile>> getUserProfile();
  
  /// Update user profile
  Future<Result<UserProfile>> updateUserProfile(Map<String, dynamic> updates);
  
  /// Update consent status
  Future<Result<void>> updateConsent({
    bool? faceDetection,
    bool? biometric,
  });
  
  /// Delete user account and all data
  Future<Result<void>> deleteAccount();
}

// ============================================================================
// Service Interfaces
// ============================================================================

abstract class BYOKManager {
  /// Store API key securely
  Future<Result<void>> storeAPIKey(String apiKey, String projectId);
  
  /// Retrieve stored API key
  Future<Result<APIKeyConfig>> getAPIKey();
  
  /// Delete stored API key
  Future<Result<void>> deleteAPIKey();
  
  /// Enable cloud backup with passphrase
  Future<Result<void>> enableCloudBackup(String passphrase);
  
  /// Disable cloud backup
  Future<Result<void>> disableCloudBackup();
  
  /// Restore API key from cloud backup
  Future<Result<void>> restoreFromBackup(String passphrase);
}

abstract class APIKeyValidator {
  /// Validate API key format
  Future<ValidationResult> validateFormat(String apiKey);
  
  /// Validate API key functionality (test API call)
  Future<ValidationResult> validateFunctionality(
    String apiKey,
    String projectId,
  );
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? errorCode;
  
  ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.errorCode,
  });
}

abstract class SecureStorageService {
  /// Write data to secure storage
  Future<void> write(String key, String value);
  
  /// Read data from secure storage
  Future<String?> read(String key);
  
  /// Delete data from secure storage
  Future<void> delete(String key);
  
  /// Check if biometric authentication is required
  Future<bool> requiresBiometric();
  
  /// Get the storage backend being used
  Future<SecureStorageBackend> getStorageBackend();
}

abstract class CloudBackupService {
  /// Encrypt and backup data to cloud
  Future<void> encryptAndBackup(String data, String passphrase);
  
  /// Restore and decrypt data from cloud
  Future<String> restoreAndDecrypt(String passphrase);
  
  /// Delete cloud backup
  Future<void> deleteBackup();
  
  /// Check if backup exists
  Future<bool> hasBackup();
}

abstract class KeyDerivationService {
  /// Derive encryption key from passphrase
  Future<DerivedKey> deriveKey({
    required String passphrase,
    required Uint8List salt,
    KDFParams? params,
  });
  
  /// Get available KDF algorithm for current platform
  Future<KDFAlgorithm> getAvailableKDF();
}

class DerivedKey {
  final Uint8List key;
  final KDFMetadata metadata;
  
  DerivedKey({required this.key, required this.metadata});
}

abstract class EncryptionService {
  /// Encrypt data using AES-256-GCM
  Future<EncryptedData> encrypt(Uint8List plaintext, Uint8List key);
  
  /// Decrypt data using AES-256-GCM
  Future<Uint8List> decrypt(EncryptedData ciphertext, Uint8List key);
}

class EncryptedData {
  final Uint8List ciphertext;
  final Uint8List nonce;
  /// Authentication tag for GCM mode (or document if appended to ciphertext)
  final Uint8List? authTag;
  
  EncryptedData({
    required this.ciphertext,
    required this.nonce,
    this.authTag, // Or make required if stored separately
  });
}

abstract class MetadataStripperService {
  /// Strip EXIF and metadata from image
  Future<File> stripMetadata(File image);
}

abstract class FaceDetectionService {
  /// Detect if face is present in image
  Future<bool> detectFace(File image);
}

abstract class BackgroundRemovalService {
  /// Remove background from clothing image
  Future<Result<File>> removeBackground(
    File image, {
    Duration timeout = const Duration(seconds: 10),
  });
}

abstract class AutoTaggerService {
  /// Analyze image and generate tags
  Future<ClothingTags> analyzeTags(File image);
}

abstract class VirtualTryOnEngine {
  /// Generate virtual try-on image
  Future<Result<GeneratedImage>> generateTryOn({
    required File userPhoto,
    required ClothingItem clothingItem,
    required GenerationMode mode,
  });
  
  /// Suggest missing pieces for outfit
  Future<Result<List<ClothingItem>>> suggestMissingPieces(
    List<ClothingItem> currentOutfit,
  );
}

abstract class VertexAIClient {
  /// Call Vertex AI model
  Future<Result<GeneratedImage>> callModel({
    required String modelId,
    required Map<String, dynamic> request,
    required String apiKey,
    required String projectId,
  });
  
  /// List available models
  Future<Result<List<String>>> listModels({
    required String apiKey,
    required String projectId,
  });
}

abstract class ModelAvailabilityService {
  /// Check if model is available
  Future<bool> isModelAvailable(String modelId, String apiKey);
  
  /// Select first available model from generation mode
  Future<Result<String>> selectAvailableModel(
    GenerationMode mode,
    String apiKey,
  );
  
  /// Validate at least one model is available
  Future<ValidationResult> validateModelAvailability(
    GenerationMode mode,
    String apiKey,
  );
}

abstract class CertificatePinningService {
  /// Update certificate pin set
  Future<void> updatePinSet(List<String> pins);
  
  /// Validate certificate against pin set
  Future<bool> validateCertificate(X509Certificate cert);
  
  /// Get current pin set
  Future<List<String>> getPinSet();
}

abstract class ImageCacheService {
  /// Generate cache key
  String generateCacheKey({
    required String userId,
    required String photoSHA256,
    required String itemId,
    required int itemVersion,
    required GenerationMode mode,
  });
  
  /// Check if cached image exists
  Future<bool> has(String cacheKey);
  
  /// Get cached image
  Future<File?> get(String cacheKey);
  
  /// Store image in cache
  Future<void> put(String cacheKey, File image, {Duration? ttl});
  
  /// Invalidate cache for item
  Future<void> invalidate(String itemId);
  
  /// Clear expired cache entries
  Future<void> clearExpired();
}

abstract class RateLimitHandler {
  /// Stream of quota events
  Stream<QuotaEvent> get quotaEvents;
  
  /// Check current quota status
  Future<QuotaStatus> checkQuota(String apiKey);
  
  /// Handle rate limit error from API
  Future<void> handleRateLimitError(int statusCode, String message);
  
  /// Increment usage counter
  Future<void> incrementUsage();
}

enum QuotaEvent {
  approaching80Percent,
  quotaExceeded,
  quotaReset,
}

abstract class QuotaTracker {
  /// Increment usage counter
  Future<void> incrementUsage(String apiKey);
  
  /// Get current quota status
  Future<QuotaStatus> getStatus(String apiKey);
  
  /// Reset daily quota
  Future<void> resetDaily();
}

abstract class UsageHistoryService {
  /// Log quota event
  Future<void> logEvent(QuotaEventType eventType, DateTime timestamp);
  
  /// Get usage history
  Future<List<UsageHistoryEntry>> getHistory();
}

abstract class BiometricConsentManager {
  /// Check if consent has been granted
  Future<bool> hasConsent();
  
  /// Request consent from user
  Future<void> requestConsent();
  
  /// Revoke consent
  Future<void> revokeConsent();
}

abstract class OnboardingController {
  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete();
  
  /// Mark onboarding as complete
  Future<void> markOnboardingComplete();
  
  /// Reset onboarding (for testing)
  Future<void> resetOnboarding();
}

abstract class OutfitCanvasController {
  /// Add item to canvas
  void addItem(ClothingItem item, LayerType layer);
  
  /// Remove item from canvas
  void removeItem(String itemId);
  
  /// Reorder layers
  void reorderLayers(List<String> itemIds);
  
  /// Save current outfit
  Future<Result<Outfit>> saveOutfit(String name);
  
  /// Clear canvas
  void clear();
  
  /// Get current items on canvas
  List<OutfitLayer> getCurrentLayers();
}

abstract class AIOutfitSuggestionService {
  /// Suggest missing pieces for outfit
  Future<Result<List<ClothingItem>>> suggestMissingPieces({
    required List<ClothingItem> currentItems,
    required String occasion,
  });
}

abstract class ErrorReporter {
  /// Report error with sanitized data
  Future<void> reportError(
    AppError error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  });
  
  /// Validate data against allow-list
  bool isAllowedData(String key, dynamic value);
}

// ============================================================================
// UI Component Props
// ============================================================================

class ClothingItemCardProps {
  final ClothingItem item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  
  ClothingItemCardProps({
    required this.item,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });
}

class OutfitCardProps {
  final Outfit outfit;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  
  OutfitCardProps({
    required this.outfit,
    required this.onTap,
    this.onDelete,
  });
}

class RateLimitBannerProps {
  final QuotaStatus quotaStatus;
  final VoidCallback onLearnMore;
  final VoidCallback onDismiss;
  
  RateLimitBannerProps({
    required this.quotaStatus,
    required this.onLearnMore,
    required this.onDismiss,
  });
}

class RateLimitModalProps {
  final QuotaStatus quotaStatus;
  final VoidCallback onEnableBilling;
  final VoidCallback onViewHistory;
  final VoidCallback onDismiss;
  
  RateLimitModalProps({
    required this.quotaStatus,
    required this.onEnableBilling,
    required this.onViewHistory,
    required this.onDismiss,
  });
}

class ConsentDialogProps {
  final String title;
  final String message;
  final List<String> bulletPoints;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  
  ConsentDialogProps({
    required this.title,
    required this.message,
    required this.bulletPoints,
    required this.onAccept,
    required this.onDecline,
  });
}
