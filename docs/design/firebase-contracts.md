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

match /users/{userId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow create: if request.auth != null && request.auth.uid == userId
    && request.resource.data.keys().hasAll(['userId', 'email', 'createdAt', 'onboardingComplete'])
    && request.resource.data.userId is string
    && request.resource.data.email is string
    && request.resource.data.createdAt is timestamp
    && request.resource.data.onboardingComplete is bool
    && (!request.resource.data.keys().hasAny(['lastLoginAt']) || request.resource.data.lastLoginAt is timestamp)
    && (!request.resource.data.keys().hasAny(['faceDetectionConsentGranted']) || request.resource.data.faceDetectionConsentGranted is bool)
    && (!request.resource.data.keys().hasAny(['biometricConsentGranted']) || request.resource.data.biometricConsentGranted is bool)
    && (!request.resource.data.keys().hasAny(['is18PlusVerified']) || request.resource.data.is18PlusVerified is bool)
    && (!request.resource.data.keys().hasAny(['verificationMethod']) || request.resource.data.verificationMethod is string)
    && !request.resource.data.keys().hasAny(['dateOfBirth']); // PII Minimization: Do not persist DOB
  allow update: if request.auth != null && request.auth.uid == userId
    && request.resource.data.userId == resource.data.userId
    && request.resource.data.email == resource.data.email
    && request.resource.data.createdAt == resource.data.createdAt
    && request.resource.data.onboardingComplete is bool
    && (!request.resource.data.keys().hasAny(['lastLoginAt']) || request.resource.data.lastLoginAt is timestamp)
    && (!request.resource.data.keys().hasAny(['faceDetectionConsentGranted']) || request.resource.data.faceDetectionConsentGranted is bool)
    && (!request.resource.data.keys().hasAny(['biometricConsentGranted']) || request.resource.data.biometricConsentGranted is bool)
    && (!request.resource.data.keys().hasAny(['is18PlusVerified']) || request.resource.data.is18PlusVerified is bool)
    && (!request.resource.data.keys().hasAny(['verificationMethod']) || request.resource.data.verificationMethod is string)
    && !request.resource.data.keys().hasAny(['dateOfBirth']); // PII Minimization: Do not persist DOB
}

### Biometric Data Handling

The `faceDetectionConsentGranted` and `biometricConsentGranted` flags in the user document control the following behaviors:

#### Face Detection Consent (`faceDetectionConsentGranted`)
- **Data Collected**: Temporary face landmarks and orientation vectors. No face embeddings (biometric templates) or raw images are stored or transmitted.
- **Processing**: Client-side only using on-device ML Kit / Vision APIs. Processing is ephemeral and occurs in-memory.
- **Storage**: **None**. No biometric data is persisted in Firestore, Storage, or any external database.
- **Consent**: Obtained via a high-visibility modal explaining that processing is local and no images are uploaded. Consent choice is stored in the `users/{userId}` document.
- **Retention**: Data is processed in real-time and discarded immediately after the feature (e.g., virtual try-on) is closed.

#### Biometric Authentication Consent (`biometricConsentGranted`)
- **Data Collected**: None accessible to the application.
- **Processing**: Handled exclusively by the OS (FaceID/TouchID/BiometricPrompt). The application only receives a cryptographic success/failure result.
- **Storage**: **None**. Biometric templates remain in the Secure Enclave/TEE and are never accessible to the app.
- **Consent**: Obtained via a system-standard biometric opt-in prompt and stored in the `users/{userId}` document.
- **Retention**: N/A (No data stored).

#### Compliance & Controls
- **Legal Compliance**: Compliant with BIPA and GDPR through explicit opt-in, lack of data persistence, and zero-transmission policy.
- **Data Erasure**: Users can revoke consent at any time in settings, which updates the flags and disables associated features. Deleting a user account removes the consent record.
- **Retention Duration**: Consent flags are retained for the duration of the account. No biometric data is retained as none is collected.

**Indexes**: None required (single document reads)

---

### Data Minimization & PII Policy

To comply with GDPR and CCPA, the system follows a strict PII minimization policy:
- **Date of Birth**: Raw DOB is collected during signup for 18+ verification purposes ONLY. It is processed in-memory and NEVER persisted to Firestore or logs.
- **Age Verification**: Only the result of the verification (`is18PlusVerified`) and the method used (`verificationMethod`) are stored.
- **Data Erasure**: Deleting a user account removes all associated profile data including email and consent records.

---

### Collection: `clothing_items/{itemId}`

**Purpose**: Store clothing item metadata

**Document Structure**:
```json
{
  "id": "string",
  "userId": "string",
  "name": "string",
  "size": "string",
  "price": "number",
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
  "createdAt": "timestamp",
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
  allow create: if request.auth != null 
    && request.resource.data.userId == request.auth.uid
    && request.resource.data.keys().hasAll(['id', 'userId', 'name', 'size', 'price', 'imageUrl', 'uploadedAt', 'createdAt', 'processingState', 'idempotencyKey'])
    && request.resource.data.id is string
    && request.resource.data.userId is string
    && request.resource.data.name is string
    && request.resource.data.size is string
    && request.resource.data.price is number && request.resource.data.price >= 0
    && request.resource.data.imageUrl is string
    && request.resource.data.uploadedAt is timestamp
    && request.resource.data.createdAt is timestamp
    && request.resource.data.processingState in ['uploading', 'processing', 'completed', 'processingFailed']
    && request.resource.data.idempotencyKey is string
    && (!request.resource.data.keys().hasAny(['tags']) || request.resource.data.tags is map);
  allow update: if request.auth != null 
    && resource.data.userId == request.auth.uid
    && request.resource.data.userId == resource.data.userId
    && request.resource.data.createdAt == resource.data.createdAt
    && request.resource.data.id == resource.data.id
    && request.resource.data.keys().hasAll(['id', 'userId', 'name', 'size', 'price', 'imageUrl', 'uploadedAt', 'createdAt', 'processingState', 'idempotencyKey'])
    && request.resource.data.id is string
    && request.resource.data.name is string
    && request.resource.data.size is string
    && request.resource.data.price is number && request.resource.data.price >= 0
    && request.resource.data.imageUrl is string
    && request.resource.data.uploadedAt is timestamp
    && request.resource.data.processingState in ['uploading', 'processing', 'completed', 'processingFailed']
    && request.resource.data.idempotencyKey is string
    && (!request.resource.data.keys().hasAny(['tags']) || request.resource.data.tags is map)
    && (!request.resource.data.keys().hasAny(['updatedAt']) || request.resource.data.updatedAt is timestamp);
  allow delete: if request.auth != null && resource.data.userId == request.auth.uid;
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
  allow create: if request.auth != null 
    && request.resource.data.userId == request.auth.uid
    && request.resource.data.keys().hasAll(['id', 'userId', 'name', 'layers', 'createdAt', 'updatedAt'])
    && request.resource.data.id is string
    && request.resource.data.userId is string
    && request.resource.data.name is string
    && request.resource.data.layers is list
    && request.resource.data.layers.size() > 0
    && request.resource.data.createdAt is timestamp
    && request.resource.data.updatedAt is timestamp
    && (!request.resource.data.keys().hasAny(['thumbnailUrl']) || request.resource.data.thumbnailUrl is string);
  allow update: if request.auth != null 
    && resource.data.userId == request.auth.uid
    && request.resource.data.userId == resource.data.userId
    && request.resource.data.id == resource.data.id
    && request.resource.data.createdAt == resource.data.createdAt
    && request.resource.data.name is string
    && request.resource.data.layers is list
    && request.resource.data.layers.size() > 0
    && request.resource.data.updatedAt is timestamp
    && (!request.resource.data.keys().hasAny(['thumbnailUrl']) || request.resource.data.thumbnailUrl is string);
  allow delete: if request.auth != null && resource.data.userId == request.auth.uid;
    && request.resource.data.userId == request.auth.uid
    && request.resource.data.keys().hasAll(['userId', 'name', 'layers', 'createdAt', 'updatedAt'])
    && request.resource.data.userId is string
    && request.resource.data.name is string
    && request.resource.data.layers is list
    && request.resource.data.createdAt is timestamp
    && request.resource.data.updatedAt is timestamp;
  allow update: if request.auth != null 
    && resource.data.userId == request.auth.uid
    && request.resource.data.userId == resource.data.userId
    && request.resource.data.createdAt == resource.data.createdAt
    && request.resource.data.keys().hasAll(['userId', 'name', 'layers', 'createdAt', 'updatedAt'])
    && request.resource.data.name is string
    && request.resource.data.layers is list
    && request.resource.data.updatedAt is timestamp;
  allow delete: if request.auth != null && resource.data.userId == request.auth.uid;
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

**Purpose**: Track API usage and quota summary

**Document Structure**:
```json
{
  "quotaTrackingId": "string (UUID)",
  "usageToday": "number",
  "resetTimeUTC": "timestamp"
}
```

**Security Rules**:
```javascript
match /quota_tracking/{userId} {
  // Clients are restricted to read-only access for their own data.
  // Quota updates must be performed by authenticated Cloud Functions with elevated privileges, never by client code.
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if false; 

  match /history/{eventId} {
    allow read: if request.auth != null && request.auth.uid == userId;
    allow write: if false;
  }
}
```

**Implementation Note**: Mutations to `usageToday`, `resetTimeUTC`, and the `history` subcollection must be performed server-side using the Admin SDK (e.g., via Cloud Functions or a secure Cloud Run instance) to prevent tampering.

**Indexes**: None required (single document reads)

**Note**: `quotaTrackingId` is a random UUID generated client-side, NOT linked to the actual API key for privacy.

---

### Subcollection: `quota_tracking/{userId}/history/{eventId}`

**Purpose**: Store detailed event records for quota usage and related actions

**Document Structure**:
```json
{
  "eventType": "tryOnGenerated | quotaReset | warning80Percent | limitReached | apiKeyUpdated",
  "timestamp": "timestamp",
  "requestCount": "number",
  "metadata": {}
}
```

**Queries**:
```dart
// Get last 50 history events for user
firestore
  .collection('quota_tracking')
  .doc(userId)
  .collection('history')
  .orderBy('timestamp', descending: true)
  .limit(50)
  .get();
```

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

**Try-on Lifecycle & Retention Policy**:
- **Lifecycle Rule**: Try-on results are subject to an automatic 90-day retention period (configurable via Remote Config `try_on_retention_days`).
- **Enforcement**: Implementers must configure **Cloud Storage Lifecycle Management** (e.g., `Age` condition) on the bucket matching this path.
- **Notification Flow**: A Cloud Function must monitor object age and trigger a push notification to the user 7 days before auto-deletion.

**Storage Quotas & Monitoring**:
- **Per-User Quota**: Default limit of 100 try-on images or 50MB per user (configurable via Remote Config `per_user_storage_limit_mb`).
- **Alerting**: Clients should monitor consumption and display a "Storage Nearly Full" warning when approaching 80% of the quota.
- **Abuse Prevention**: Upload functions must verify the user's current storage count/size before permitting new try-on generations.

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

**Security & Risk Assessment**:
> [!WARNING]
> Storing encrypted API keys in Firebase Storage creates a single point of failure. If the user's Firebase account is compromised, the attacker can download the backup and attempt offline brute-force decryption.

**Recommended Alternatives**:
- Use **Google Cloud Secret Manager** for server-side key management.
- Implement server-side key storage protected by Multi-Factor Authentication (MFA).

**Mitigation Policies**:
- **Key Rotation**: API keys should be rotated every 90 days. Backups must be overwritten or deleted upon rotation.
- **Expiration**: Backups should have a limited TTL (e.g., 30 days) and be automatically cleaned up by a lifecycle policy if not refreshed.
- **Audit Logging**: All access to this file must be logged via Cloud Audit Logs or a custom logging function for security reviews.
- **Brute-Force Protection**: 
    - Use Argon2id with high memory cost for the KDF.
    - Implement server-side rate-limiting and throttling for decryption attempts (client-side controls can be bypassed).
    - Consider implementing account lockout after N failed decryption attempts within a time window.
**Content Structure**:
```json
{
  "kdf": {
    "algorithm": "argon2id",
    "salt": "base64_encoded_salt",
    "params": {
      "time": 3,
      "memory": 67108864,
      "parallelism": 1,
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
  // Requires recent re-authentication (within 5 minutes) before access.
  // This helps mitigate sessions hijacked via XSS or stolen devices.
  allow read, write: if request.auth != null 
    && request.auth.uid == userId
    && request.auth.token.auth_time > (request.time.toMillis() / 1000) - (5 * 60);
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
  "clothing": -1,
  "try_on_retention_days": 90
}
```

**storage_quota_config**:
```json
{
  "per_user_storage_limit_mb": 50,
  "quota_warning_threshold": 0.8
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

## Required Cloud Functions

### 1. `onClothingItemCreate`
- **Trigger**: `firestore.document('clothing_items/{itemId}').onCreate`
- **Responsibilities**: 
    - Trigger background removal service for new uploads. 
    - Update `processingState` to `processing`. 
    - Upon completion/failure, update `processedImageUrl`, `failureReason`, and `retryCount`.
- **Security**: Automated internal trigger; requires service account with write access to `clothing_items`.
- **Collections Touched**: `clothing_items`

### 2. `incrementQuota` (Callable)
- **Trigger**: `https.onCall` (Authenticated)
- **Responsibilities**: 
    - Atomically increment `usageToday` in `quota_tracking/{userId}`.
    - Append an event to the `history` subcollection.
    - Enforce idempotency and validate that `usageToday` does not exceed limits before allowing sensitive API calls.
- **Security**: Must verify `request.auth != null`.
- **Collections Touched**: `quota_tracking`, `quota_tracking/{userId}/history/*`

### 3. `setAgeVerificationClaims`
- **Trigger**: Internal Admin invocation (called by Auth Blocking Functions or manual verification flow).
- **Responsibilities**: 
    - Update Firebase Auth Custom Claims (e.g., `ageVerified: true`, `verificationMethod`).
- **Security**: Requires elevated Admin privileges; must never be callable by client code.
- **Touched Assets**: Firebase Authentication Custom Claims.

### 4. `cleanupOldTryOns` (Scheduled)
- **Trigger**: `pubsub.schedule('every 24 hours')`
- **Responsibilities**: 
    - List and delete files in `users/{userId}/try-ons/` older than the retention period (90 days).
    - Prune records in `quota_tracking/{userId}/history` subcollection older than 90 days.
- **Security**: Internal scheduled job.
- **Touched Assets**: Firebase Storage (`users/*/try-ons/*`), `quota_tracking` history subcollections.

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

