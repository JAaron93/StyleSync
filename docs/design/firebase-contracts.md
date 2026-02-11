# Firebase API Contracts

## Firestore Collections

### Collection: `users/{userId}`

**Purpose**: Store user profile and preferences

**Document Structure**:
```json
{
  "userId": "string",
  "email": "string",
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp | null",
  "onboardingComplete": "boolean",
  "faceDetectionConsentGranted": "boolean",
  "biometricConsentGranted": "boolean",
  "is18PlusVerified": "boolean",
  "verificationMethod": "selfReported | thirdPartyVerified"
}
```

**Security Rules**:
```javascript
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

**Indexes**: None required (single document reads)

---

### Collection: `clothing_items/{itemId}`

**Purpose**: Store clothing item metadata

**Document Structure**:
```json
{
  "id": "string",
  "userId": "string",
  "imageUrl": "string",
  "thumbnailUrl": "string",
  "processedImageUrl": "string | null",
  "tags": {
    "category": "tops | bottoms | shoes | accessories | outerwear",
    "colors": ["string"],
    "seasons": ["spring | summer | fall | winter | allSeason"],
    "additionalAttributes": {}
  },
  "uploadedAt": "timestamp",
  "updatedAt": "timestamp | null",
  "processingState": "uploading | processing | completed | processingFailed",
  "failureReason": "string | null",
  "retryCount": "number",
  "idempotencyKey": "string",
  "metadata": {}
}
```

**Security Rules**:
```javascript
match /clothing_items/{itemId} {
  allow read: if request.auth != null && resource.data.userId == request.auth.uid;
  allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
  allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
}
```

**Indexes**:
- `userId` (ascending) + `uploadedAt` (descending)
- `userId` (ascending) + `tags.category` (ascending) + `uploadedAt` (descending)
- `userId` (ascending) + `processingState` (ascending)
- `idempotencyKey` (ascending) - for deduplication

**Queries**:
```dart
// Get all items for user
firestore
  .collection('clothing_items')
  .where('userId', isEqualTo: userId)
  .orderBy('uploadedAt', descending: true)
  .get();

// Get items by category
firestore
  .collection('clothing_items')
  .where('userId', isEqualTo: userId)
  .where('tags.category', isEqualTo: 'tops')
  .orderBy('uploadedAt', descending: true)
  .get();

// Check for existing item by idempotency key
firestore
  .collection('clothing_items')
  .where('idempotencyKey', isEqualTo: key)
  .limit(1)
  .get();
```

---

### Collection: `outfits/{outfitId}`

**Purpose**: Store saved outfit combinations

**Document Structure**:
```json
{
  "id": "string",
  "userId": "string",
  "name": "string",
  "layers": [
    {
      "type": "base | mid | outer | accessories",
      "clothingItemId": "string",
      "zIndex": "number",
      "positioning": {}
    }
  ],
  "thumbnailUrl": "string | null",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Security Rules**:
```javascript
match /outfits/{outfitId} {
  allow read: if request.auth != null && resource.data.userId == request.auth.uid;
  allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
  allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
}
```

**Indexes**:
- `userId` (ascending) + `updatedAt` (descending)

**Queries**:
```dart
// Get all outfits for user
firestore
  .collection('outfits')
  .where('userId', isEqualTo: userId)
  .orderBy('updatedAt', descending: true)
  .get();
```

---

### Collection: `quota_tracking/{userId}`

**Purpose**: Track API usage and quota status

**Document Structure**:
```json
{
  "quotaTrackingId": "string (UUID)",
  "usageToday": "number",
  "resetTimeUTC": "timestamp",
  "history": [
    {
      "eventType": "tryOnGenerated | quotaReset | warning80Percent | limitReached | apiKeyUpdated",
      "timestamp": "timestamp",
      "requestCount": "number",
      "metadata": {}
    }
  ]
}
```

**Security Rules**:
```javascript
match /quota_tracking/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

**Indexes**: None required (single document reads)

**Note**: `quotaTrackingId` is a random UUID generated client-side, NOT linked to the actual API key for privacy.

---

## Firebase Storage Structure

### Path: `users/{userId}/clothing/{itemId}/`

**Files**:
- `original.jpg` - Original uploaded photo
- `processed.jpg` - Background-removed photo
- `thumbnail.jpg` - Thumbnail for list views

**Metadata**:
```json
{
  "contentType": "image/jpeg",
  "customMetadata": {
    "userId": "string",
    "itemId": "string",
    "uploadedAt": "ISO8601 timestamp"
  }
}
```

**Security Rules**:
```javascript
match /users/{userId}/clothing/{itemId}/{filename} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if request.auth != null && request.auth.uid == userId;
  allow delete: if request.auth != null && request.auth.uid == userId;
}
```

---

### Path: `users/{userId}/try-ons/{tryOnId}.jpg`

**Purpose**: Store generated try-on results (user-controlled deletion)

**Metadata**:
```json
{
  "contentType": "image/jpeg",
  "customMetadata": {
    "userId": "string",
    "clothingItemId": "string",
    "modelUsed": "string",
    "generatedAt": "ISO8601 timestamp"
  }
}
```

**Security Rules**:
```javascript
match /users/{userId}/try-ons/{tryOnId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if request.auth != null && request.auth.uid == userId;
  allow delete: if request.auth != null && request.auth.uid == userId;
}
```

**Note**: User input photos are NEVER stored here. Only generated results.

---

### Path: `users/{userId}/outfits/{outfitId}_thumbnail.jpg`

**Purpose**: Store outfit preview thumbnails

**Security Rules**:
```javascript
match /users/{userId}/outfits/{filename} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if request.auth != null && request.auth.uid == userId;
  allow delete: if request.auth != null && request.auth.uid == userId;
}
```

---

### Path: `users/{userId}/api_key_backup.json`

**Purpose**: Store encrypted API key backup (optional, user-enabled)

**Content Structure**:
```json
{
  "kdf": {
    "algorithm": "argon2id | pbkdf2",
    "salt": "base64_encoded_salt",
    "params": {
      "time": 3,
      "memory": 67108864,
      "parallelism": 4,
      "version": 19
    }
  },
  "encrypted_data": "base64_encoded_ciphertext",
  "nonce": "base64_encoded_nonce",
  "createdAt": "ISO8601 timestamp",
  "updatedAt": "ISO8601 timestamp"
}
```

**Security Rules**:
```javascript
match /users/{userId}/api_key_backup.json {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

---

## Firebase Remote Config

### Parameters

**certificate_pins**:
```json
{
  "pins": [
    "sha256/primary_pin_base64",
    "sha256/backup_pin_1_base64",
    "sha256/backup_pin_2_base64"
  ],
  "lastUpdated": "ISO8601 timestamp"
}
```

**cache_ttl_config**:
```json
{
  "tryOn": 86400,
  "thumbnails": 604800,
  "clothing": -1
}
```

**feature_flags**:
```json
{
  "enableAISuggestions": true,
  "enableCloudBackup": true,
  "maintenanceMode": false
}
```

**force_update_config**:
```json
{
  "minimumVersion": "1.0.0",
  "criticalUpdate": false,
  "updateMessage": "A new version is available"
}
```

---

## Firebase Authentication

### Custom Claims

After age verification, set custom claim:
```json
{
  "ageVerified": true,
  "verificationMethod": "selfReported | thirdPartyVerified",
  "verifiedAt": "ISO8601 timestamp"
}
```

### Blocking Functions

**beforeCreate**:
- Verify age from DOB
- Set custom claims if verified
- Reject if under 18

**beforeSignIn**:
- Check age verification status
- Enforce 24-hour cooldown after failed attempts

