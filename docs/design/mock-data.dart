// StyleSync Mock Data
// This file contains mock data for prototype testing and development

import 'data-models.dart';

// ============================================================================
// Mock User Profiles
// ============================================================================

final mockUserProfile = UserProfile(
  userId: 'user_123',
  email: 'user@example.com',
  createdAt: DateTime(2026, 1, 1),
  lastLoginAt: DateTime(2026, 2, 10),
  onboardingComplete: true,
  faceDetectionConsentGranted: true,
  biometricConsentGranted: true,
  is18PlusVerified: true,
  verificationMethod: AgeVerificationMethod.selfReported,
);

final mockNewUser = UserProfile(
  userId: 'user_456',
  email: 'newuser@example.com',
  createdAt: DateTime(2026, 2, 10),
  lastLoginAt: null,
  onboardingComplete: false,
  faceDetectionConsentGranted: false,
  biometricConsentGranted: false,
  is18PlusVerified: true,
  verificationMethod: AgeVerificationMethod.selfReported,
);

// ============================================================================
// Mock Clothing Items
// ============================================================================

final mockClothingItems = [
  ClothingItem(
    id: 'item_001',
    userId: 'user_123',
    imageUrl: 'https://example.com/clothing/item_001.jpg',
    thumbnailUrl: 'https://example.com/clothing/item_001_thumb.jpg',
    processedImageUrl: 'https://example.com/clothing/item_001_processed.jpg',
    tags: ClothingTags(
      category: ClothingCategory.tops,
      colors: ['Blue', 'White'],
      seasons: [Season.summer, Season.allSeason],
      additionalAttributes: {'style': 'casual', 'fit': 'regular'},
    ),
    uploadedAt: DateTime(2026, 1, 15),
    updatedAt: null,
    processingState: ItemProcessingState.completed,
    failureReason: null,
    retryCount: 0,
    idempotencyKey: 'idem_001',
    metadata: {},
  ),
  ClothingItem(
    id: 'item_002',
    userId: 'user_123',
    imageUrl: 'https://example.com/clothing/item_002.jpg',
    thumbnailUrl: 'https://example.com/clothing/item_002_thumb.jpg',
    processedImageUrl: 'https://example.com/clothing/item_002_processed.jpg',
    tags: ClothingTags(
      category: ClothingCategory.bottoms,
      colors: ['Black'],
      seasons: [Season.allSeason],
      additionalAttributes: {'style': 'casual', 'fit': 'slim'},
    ),
    uploadedAt: DateTime(2026, 1, 16),
    updatedAt: null,
    processingState: ItemProcessingState.completed,
    failureReason: null,
    retryCount: 0,
    idempotencyKey: 'idem_002',
    metadata: {},
  ),
  ClothingItem(
    id: 'item_003',
    userId: 'user_123',
    imageUrl: 'https://example.com/clothing/item_003.jpg',
    thumbnailUrl: 'https://example.com/clothing/item_003_thumb.jpg',
    processedImageUrl: null,
    tags: ClothingTags(
      category: ClothingCategory.shoes,
      colors: ['White'],
      seasons: [Season.allSeason],
      additionalAttributes: {'style': 'sneakers'},
    ),
    uploadedAt: DateTime(2026, 1, 20),
    updatedAt: null,
    processingState: ItemProcessingState.processing,
    failureReason: null,
    retryCount: 0,
    idempotencyKey: 'idem_003',
    metadata: {},
  ),
  ClothingItem(
    id: 'item_004',
    userId: 'user_123',
    imageUrl: 'https://example.com/clothing/item_004.jpg',
    thumbnailUrl: 'https://example.com/clothing/item_004_thumb.jpg',
    processedImageUrl: null,
    tags: ClothingTags(
      category: ClothingCategory.outerwear,
      colors: ['Brown'],
      seasons: [Season.fall, Season.winter],
      additionalAttributes: {'style': 'jacket', 'material': 'leather'},
    ),
    uploadedAt: DateTime(2026, 1, 25),
    updatedAt: null,
    processingState: ItemProcessingState.processingFailed,
    failureReason: 'Background removal timeout',
    retryCount: 2,
    idempotencyKey: 'idem_004',
    metadata: {},
  ),
  ClothingItem(
    id: 'item_005',
    userId: 'user_123',
    imageUrl: 'https://example.com/clothing/item_005.jpg',
    thumbnailUrl: 'https://example.com/clothing/item_005_thumb.jpg',
    processedImageUrl: 'https://example.com/clothing/item_005_processed.jpg',
    tags: ClothingTags(
      category: ClothingCategory.accessories,
      colors: ['Black', 'Silver'],
      seasons: [Season.allSeason],
      additionalAttributes: {'type': 'watch'},
    ),
    uploadedAt: DateTime(2026, 2, 1),
    updatedAt: null,
    processingState: ItemProcessingState.completed,
    failureReason: null,
    retryCount: 0,
    idempotencyKey: 'idem_005',
    metadata: {},
  ),
];

// ============================================================================
// Mock Outfits
// ============================================================================

final mockOutfits = [
  Outfit(
    id: 'outfit_001',
    userId: 'user_123',
    name: 'Summer Casual',
    layers: [
      OutfitLayer(
        type: LayerType.mid,
        clothingItemId: 'item_001',
        zIndex: 1,
        positioning: {'x': 0, 'y': 0},
      ),
      OutfitLayer(
        type: LayerType.mid,
        clothingItemId: 'item_002',
        zIndex: 2,
        positioning: {'x': 0, 'y': 100},
      ),
      OutfitLayer(
        type: LayerType.accessories,
        clothingItemId: 'item_003',
        zIndex: 3,
        positioning: {'x': 0, 'y': 200},
      ),
    ],
    thumbnailUrl: 'https://example.com/outfits/outfit_001_thumb.jpg',
    createdAt: DateTime(2026, 1, 20),
    updatedAt: DateTime(2026, 1, 20),
  ),
  Outfit(
    id: 'outfit_002',
    userId: 'user_123',
    name: 'Work Professional',
    layers: [
      OutfitLayer(
        type: LayerType.mid,
        clothingItemId: 'item_001',
        zIndex: 1,
        positioning: {'x': 0, 'y': 0},
      ),
      OutfitLayer(
        type: LayerType.mid,
        clothingItemId: 'item_002',
        zIndex: 2,
        positioning: {'x': 0, 'y': 100},
      ),
      OutfitLayer(
        type: LayerType.outer,
        clothingItemId: 'item_004',
        zIndex: 3,
        positioning: {'x': 0, 'y': 0},
      ),
      OutfitLayer(
        type: LayerType.accessories,
        clothingItemId: 'item_005',
        zIndex: 4,
        positioning: {'x': 50, 'y': 50},
      ),
    ],
    thumbnailUrl: 'https://example.com/outfits/outfit_002_thumb.jpg',
    createdAt: DateTime(2026, 2, 1),
    updatedAt: DateTime(2026, 2, 5),
  ),
];

// ============================================================================
// Mock Quota Status
// ============================================================================

final mockQuotaStatus80Percent = QuotaStatus(
  usedToday: 80,
  estimatedRemaining: 20,
  resetTimeUTC: DateTime.utc(2026, 2, 11, 0, 0, 0),
  isExceeded: false,
  usagePercentage: 0.80,
  quotaTrackingId: 'tracking_uuid_123',
);

final mockQuotaStatusExceeded = QuotaStatus(
  usedToday: 100,
  estimatedRemaining: 0,
  resetTimeUTC: DateTime.utc(2026, 2, 11, 0, 0, 0),
  isExceeded: true,
  usagePercentage: 1.0,
  quotaTrackingId: 'tracking_uuid_123',
);

final mockQuotaStatusNormal = QuotaStatus(
  usedToday: 45,
  estimatedRemaining: 55,
  resetTimeUTC: DateTime.utc(2026, 2, 11, 0, 0, 0),
  isExceeded: false,
  usagePercentage: 0.45,
  quotaTrackingId: 'tracking_uuid_123',
);

// ============================================================================
// Mock Usage History
// ============================================================================

final mockUsageHistory = [
  UsageHistoryEntry(
    id: 'history_001',
    userId: 'user_123',
    eventType: QuotaEventType.tryOnGenerated,
    timestamp: DateTime(2026, 2, 10, 14, 30),
    requestCount: 1,
    metadata: {'modelUsed': 'gemini-2.5-flash-image'},
  ),
  UsageHistoryEntry(
    id: 'history_002',
    userId: 'user_123',
    eventType: QuotaEventType.tryOnGenerated,
    timestamp: DateTime(2026, 2, 10, 13, 45),
    requestCount: 1,
    metadata: {'modelUsed': 'virtual-try-on-preview-08-04'},
  ),
  UsageHistoryEntry(
    id: 'history_003',
    userId: 'user_123',
    eventType: QuotaEventType.warning80Percent,
    timestamp: DateTime(2026, 2, 9, 23, 30),
    requestCount: 80,
    metadata: {},
  ),
  UsageHistoryEntry(
    id: 'history_004',
    userId: 'user_123',
    eventType: QuotaEventType.quotaReset,
    timestamp: DateTime(2026, 2, 10, 0, 0),
    requestCount: 0,
    metadata: {},
  ),
];

// ============================================================================
// Mock Storage Quota
// ============================================================================

final mockStorageQuotaNormal = StorageQuota(
  itemCount: 45,
  maxItems: 500,
  bytesUsed: 1288490188, // ~1.2GB
  maxBytes: 2147483648, // 2GB
  isExceeded: false,
);

final mockStorageQuotaNearLimit = StorageQuota(
  itemCount: 480,
  maxItems: 500,
  bytesUsed: 2040109465, // ~1.9GB
  maxBytes: 2147483648, // 2GB
  isExceeded: false,
);

final mockStorageQuotaExceeded = StorageQuota(
  itemCount: 500,
  maxItems: 500,
  bytesUsed: 2147483648, // 2GB
  maxBytes: 2147483648, // 2GB
  isExceeded: true,
);

// ============================================================================
// Mock API Key Config
// ============================================================================

final mockAPIKeyConfig = APIKeyConfig(
  apiKey: 'AIzaSy*********************',
  projectId: 'my-project-123',
  createdAt: DateTime(2026, 1, 1),
  lastValidated: DateTime(2026, 2, 10),
  cloudBackupEnabled: false,
  storageBackend: SecureStorageBackend.hardwareBacked,
);

final mockAPIKeyConfigWithBackup = APIKeyConfig(
  apiKey: 'AIzaSy*********************',
  projectId: 'my-project-123',
  createdAt: DateTime(2026, 1, 1),
  lastValidated: DateTime(2026, 2, 10),
  cloudBackupEnabled: true,
  storageBackend: SecureStorageBackend.strongBox,
);

// ============================================================================
// Mock Generated Images
// ============================================================================

final mockGeneratedImages = [
  GeneratedImage(
    id: 'gen_001',
    userId: 'user_123',
    imageUrl: 'https://example.com/try-ons/gen_001.jpg',
    modelUsed: 'virtual-try-on-preview-08-04',
    mode: GenerationMode.tryOn,
    generatedAt: DateTime(2026, 2, 10, 14, 30),
    clothingItemId: 'item_001',
    metadata: {'generationTime': 15000},
  ),
  GeneratedImage(
    id: 'gen_002',
    userId: 'user_123',
    imageUrl: 'https://example.com/try-ons/gen_002.jpg',
    modelUsed: 'gemini-2.5-flash-image',
    mode: GenerationMode.speed,
    generatedAt: DateTime(2026, 2, 10, 13, 45),
    clothingItemId: 'item_002',
    metadata: {'generationTime': 8000},
  ),
];

// ============================================================================
// Mock Errors
// ============================================================================

final mockNetworkError = NetworkError(
  'Unable to connect to the network',
  code: 'NETWORK_ERROR',
);

final mockAPIError = APIError(
  'Invalid API key',
  statusCode: 401,
  code: 'UNAUTHENTICATED',
);

final mockQuotaExceededError = QuotaExceededError(
  'Daily quota exceeded',
  DateTime.utc(2026, 2, 11, 0, 0, 0),
  statusCode: 429,
  code: 'RESOURCE_EXHAUSTED',
);

final mockValidationError = ValidationError(
  'Validation failed',
  {
    'apiKey': 'API key is required',
    'projectId': 'Project ID must be alphanumeric',
  },
  code: 'VALIDATION_ERROR',
);

final mockStorageQuotaError = StorageQuotaError(
  'Storage quota exceeded',
  mockStorageQuotaExceeded,
  code: 'STORAGE_QUOTA_EXCEEDED',
);

// ============================================================================
// Helper Functions for Mock Data
// ============================================================================

/// Get mock clothing items by category
List<ClothingItem> getMockItemsByCategory(ClothingCategory category) {
  return mockClothingItems
      .where((item) => item.tags.category == category)
      .toList();
}

/// Get mock clothing items by season
List<ClothingItem> getMockItemsBySeason(Season season) {
  return mockClothingItems
      .where((item) => item.tags.seasons.contains(season))
      .toList();
}

/// Get mock outfit by ID
Outfit? getMockOutfitById(String outfitId) {
  try {
    return mockOutfits.firstWhere((outfit) => outfit.id == outfitId);
  } catch (e) {
    return null;
  }
}

/// Get mock clothing item by ID
ClothingItem? getMockItemById(String itemId) {
  try {
    return mockClothingItems.firstWhere((item) => item.id == itemId);
  } catch (e) {
    return null;
  }
}

/// Simulate quota increment
QuotaStatus simulateQuotaIncrement(QuotaStatus current) {
  final newUsed = current.usedToday + 1;
  return QuotaStatus(
    usedToday: newUsed,
    estimatedRemaining: 100 - newUsed,
    resetTimeUTC: current.resetTimeUTC,
    isExceeded: newUsed >= 100,
    usagePercentage: newUsed / 100.0,
    quotaTrackingId: current.quotaTrackingId,
  );
}
