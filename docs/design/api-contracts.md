# StyleSync - API Data Contracts & Component Interfaces

## Overview
This document defines the data structures, API contracts, and component interfaces for StyleSync. These contracts serve as the agreement between frontend components, backend services, and external APIs.

## Table of Contents
1. [Data Models](#data-models)
2. [Firebase API Contracts](#firebase-api-contracts)
3. [Vertex AI API Contracts](#vertex-ai-api-contracts)
4. [Component Interfaces](#component-interfaces)
5. [State Management](#state-management)
6. [Mock Data](#mock-data)

---

## 1. Data Models

### 1.1 User Profile

```dart
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
  
  UserProfile({
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
      // Log invalid value for monitoring
      print('Warning: Unknown AgeVerificationMethod value: $value');
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
```

### 1.2 Clothing Item

```dart
class ClothingItem {
  final String id;
  final String userId;
  final String imageUrl;
  final String thumbnailUrl;
  final String? processedImageUrl; // Background removed
  final ClothingTags tags;
  final DateTime uploadedAt;
  final DateTime? updatedAt;
  final ItemProcessingState processingState;
  final String? failureReason;
  final int retryCount;
  final String idempotencyKey;
  final Map<String, dynamic> metadata;
  
  ClothingItem({
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
      processingState: ItemProcessingState.values.firstWhere(
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      processingState: ItemProcessingState.values.firstWhere(
        (e) => e.toString() == 'ItemProcessingState.${json['processingState']}',
        orElse: () => ItemProcessingState.unknown,
      ),
      metadata: (json['metadata'] is Map) 
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},
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
  
  ClothingTags({
    required this.category,
    required this.colors,
    required this.seasons,
    required this.additionalAttributes,
  });
  
  factory ClothingTags.fromJson(Map<String, dynamic> json) {
    return ClothingTags(
      category: ClothingCategory.values.firstWhere(
        (e) => e.toString() == 'ClothingCategory.${json['category']}',
        orElse: () => ClothingCategory.unknown,
      ),
      colors: (json['colors'] as List?)
          ?.where((c) => c is String)
          .cast<String>()
          .toList() ?? [],
      seasons: (json['seasons'] as List)
          .map((s) => Season.values.firstWhere(
                (e) => e.toString() == 'Season.$s',
                orElse: () => Season.unknown,
              ))
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
```

### 1.3 Outfit

```dart
class Outfit {
  final String id;
  final String userId;
  final String name;
  final List<OutfitLayer> layers;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Outfit({
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
          .map((layerJson) => OutfitLayer.fromJson(layerJson as Map<String, dynamic>))
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
  final Map<String, dynamic>? positioning;
  
  OutfitLayer({
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
      type: LayerType.values.firstWhere(
        (e) => e.toString() == 'LayerType.${json['type']}',
        orElse: () => LayerType.unknown,
      ),
      clothingItemId: json['clothingItemId'] as String,
      index: json['index'] as int,
      isVisible: json['isVisible'] as bool,
      opacity: (json['opacity'] as num).toDouble(),
      assetReference: json['assetReference'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>,
      positioning: json['positioning'] as Map<String, dynamic>?,
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
}

enum LayerType {
  base,
  mid,
  outer,
  accessories,
  unknown,
}
```

---

## 2. Firebase API Contracts

See `firebase-contracts.md` for complete Firebase API documentation including:
- Firestore collections and schemas
- Firebase Storage structure
- Security rules
- Indexes and queries
- Remote Config parameters

---

## 3. Vertex AI API Contracts

See `vertex-ai-contracts.md` for complete Vertex AI API documentation including:
- Virtual Try-On API
- Gemini Image Generation API
- Model availability checking
- Error handling and retry strategies
- Client-side caching

---

## 4. Component Interfaces

See `component-interfaces.dart` for complete component interface definitions including:
- Repository interfaces
- Service interfaces
- UI component props

---

## 5. State Management

### Riverpod Providers

```dart
// User state
final userProfileProvider = StreamProvider<UserProfile>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) throw Exception('Not authenticated');
  return ref.watch(userRepositoryProvider).getUserProfileStream(userId);
});

// Clothing items state
final clothingItemsProvider = StreamProvider<List<ClothingItem>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ref.watch(clothingRepositoryProvider).getClothingItemsStream(userId);
});

// Filtered clothing items
final filteredClothingItemsProvider = Provider<List<ClothingItem>>((ref) {
  final items = ref.watch(clothingItemsProvider).value ?? [];
  final filter = ref.watch(clothingFilterProvider);
  
  return items.where((item) {
    if (filter.category != null && item.tags.category != filter.category) {
      return false;
    }
    if (filter.season != null && !item.tags.seasons.contains(filter.season)) {
      return false;
    }
    return true;
  }).toList();
});

// Quota status state
final quotaStatusProvider = StreamProvider<QuotaStatus>((ref) {
  return ref.watch(rateLimitHandlerProvider).quotaStatusStream;
});

// Outfits state
final outfitsProvider = StreamProvider<List<Outfit>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ref.watch(outfitRepositoryProvider).getOutfitsStream(userId);
});

// API key config state
final apiKeyConfigProvider = FutureProvider<APIKeyConfig?>((ref) {
  return ref.watch(byokManagerProvider).getAPIKey().then(
    (result) => result.when(
      success: (config) => config,
      failure: (_) => null,
    ),
  );
});
```

---

## 6. Mock Data

See `mock-data.dart` for comprehensive mock data including:
- Mock user profiles
- Mock clothing items
- Mock outfits
- Mock quota status
- Mock usage history
- Mock errors
- Helper functions

---

## Data Flow Diagrams

### Upload Flow Data Flow

```
User selects photo
    ↓
File → MetadataStripper → Cleaned File
    ↓
Cleaned File → FaceDetectionService → Boolean (face detected)
    ↓
Cleaned File → BackgroundRemovalService → Processed File
    ↓
Processed File → AutoTaggerService → ClothingTags
    ↓
{Processed File, ClothingTags} → ClothingRepository
    ↓
ClothingRepository → Firebase Storage (upload file)
    ↓
Firebase Storage → imageUrl
    ↓
{imageUrl, ClothingTags, metadata} → Firestore
    ↓
Firestore → ClothingItem (with ID)
    ↓
ClothingItem → UI (display in closet)
```

### Try-On Generation Data Flow

```
User selects {ClothingItem, Photo, GenerationMode}
    ↓
BiometricConsentManager → Check consent
    ↓
ImageCacheService → Check cache
    ↓ (cache miss)
RateLimitHandler → Check quota
    ↓
{Photo, ClothingItem.imageUrl} → VertexAIClient
    ↓
VertexAIClient → Vertex AI API (HTTP request)
    ↓
Vertex AI API → Base64 encoded image
    ↓
Base64 image → Decode → File
    ↓
File → ImageCacheService (store)
    ↓
File → UI (display result)
    ↓
QuotaTracker → Increment usage
    ↓
UsageHistoryService → Log event
```

### Quota Management Data Flow

```
API call initiated
    ↓
QuotaTracker → Increment counter
    ↓
QuotaTracker → Check threshold
    ↓ (>= 80%)
RateLimitHandler → Emit warning event
    ↓
UI → Display warning banner
    ↓ (>= 100%)
RateLimitHandler → Emit exceeded event
    ↓
UI → Display rate limit modal
    ↓
UI → Disable try-on features
    ↓
Midnight UTC
    ↓
QuotaTracker → Reset counter
    ↓
RateLimitHandler → Emit reset event
    ↓
UI → Re-enable features
```

---

## API Endpoint Summary

### Firebase Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/users/{userId}` | GET | Get user profile |
| `/users/{userId}` | PUT | Update user profile |
| `/clothing_items` | GET | List clothing items |
| `/clothing_items` | POST | Create clothing item |
| `/clothing_items/{itemId}` | GET | Get clothing item |
| `/clothing_items/{itemId}` | PUT | Update clothing item |
| `/clothing_items/{itemId}` | DELETE | Delete clothing item |
| `/outfits` | GET | List outfits |
| `/outfits` | POST | Create outfit |
| `/outfits/{outfitId}` | GET | Get outfit |
| `/outfits/{outfitId}` | PUT | Update outfit |
| `/outfits/{outfitId}` | DELETE | Delete outfit |
| `/quota_tracking/{userId}` | GET | Get quota status |
| `/quota_tracking/{userId}` | PUT | Update quota status |

### Vertex AI Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/models/virtual-try-on-preview-08-04:predict` | POST | Generate try-on |
| `/models/{modelId}:generateContent` | POST | Generate image |
| `/models` | GET | List available models |

---

## Error Code Reference

### HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Process response |
| 400 | Bad Request | Show validation error |
| 401 | Unauthorized | Prompt for API key |
| 403 | Forbidden | Show permission error |
| 429 | Rate Limited | Show quota modal |
| 500 | Server Error | Retry with backoff |
| 503 | Unavailable | Retry with backoff |

### Application Error Codes

| Code | Type | User Message |
|------|------|--------------|
| `NETWORK_ERROR` | NetworkError | "Unable to connect. Check your internet connection." |
| `UNAUTHENTICATED` | APIError | "Invalid API key. Please update your key in settings." |
| `PERMISSION_DENIED` | APIError | "Vertex AI API not enabled. Please enable it in Google Cloud Console." |
| `RESOURCE_EXHAUSTED` | QuotaExceededError | "Daily quota exceeded. Resets at midnight UTC." |
| `VALIDATION_ERROR` | ValidationError | "Please check your input and try again." |
| `STORAGE_QUOTA_EXCEEDED` | StorageQuotaError | "Storage limit reached. Delete some items to continue." |

---

## Testing Considerations

### Mock API Responses

For testing, use mock responses that match the actual API contracts:

```dart
// Mock successful try-on response
final mockTryOnResponse = {
  'predictions': [{
    'bytesBase64Encoded': 'iVBORw0KGgoAAAANSUhEUgAA...',
    'mimeType': 'image/jpeg'
  }],
  'metadata': {
    'modelVersion': 'virtual-try-on-preview-08-04'
  }
};

// Mock quota exceeded response
final mockQuotaExceededResponse = {
  'error': {
    'code': 429,
    'message': 'Quota exceeded',
    'status': 'RESOURCE_EXHAUSTED'
  }
};
```

### Integration Test Scenarios

1. **Upload Flow**: Test complete upload with all processing steps
2. **Try-On Flow**: Test generation with caching and quota tracking
3. **Quota Management**: Test warning, exceeded, and reset scenarios
4. **Error Handling**: Test all error types and recovery strategies
5. **Consent Flows**: Test first-time and subsequent consent dialogs

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-10 | Initial API contracts |

