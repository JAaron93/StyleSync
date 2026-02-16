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
    && (!request.resource.data.keys().hasAny(['verificationMethod']) || request.resource.data.verificationMethod in ['selfReported', 'thirdPartyVerified'])
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
    && (!request.resource.data.keys().hasAny(['verificationMethod']) || request.resource.data.verificationMethod in ['selfReported', 'thirdPartyVerified'])
    && !request.resource.data.keys().hasAny(['dateOfBirth']); // PII Minimization: Do not persist DOB
}
```

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
- **Decryption Model**: Decryption occurs **client-side** using Argon2id KDF with the user's password. The server never sees the decryption key or plaintext API key.
- **Key Rotation**: API keys should be rotated every 90 days. Backups must be overwritten or deleted upon rotation.
- **Expiration**: Backups should have a limited TTL (e.g., 30 days) and be automatically cleaned up by a lifecycle policy if not refreshed.
- **Audit Logging**: All access to this file must be logged via Cloud Audit Logs or a custom logging function for security reviews.
- **Offline Brute-Force Protection** (since decryption is client-side):
    - Use the strong Argon2id parameters specified above (64MB memory cost, 3 iterations) to maximize brute-force resistance.
    - **Per-file unique salts**: Each backup file includes a unique cryptographically random salt (see `kdf.salt` in Content Structure below). This prevents rainbow table attacks and ensures identical passwords produce different ciphertext across files.
    - **Server-Side Pepper**: An optional server-managed secret adds an additional layer of protection. Implementation details:
        - The pepper is stored in **Google Cloud Secret Manager** (preferred) or a **TEE-backed secure enclave**.
        - The schema includes an optional `pepper_id` field referencing the secret version (e.g., `"pepper_id": "projects/stylesync/secrets/api-key-pepper/versions/3"`).
        - **Pepper Retrieval Flow**: The client calls the `getDecryptionPepper` Cloud Function (see Required Cloud Functions) which verifies authentication, retrieves the pepper from Secret Manager, and returns it over TLS. The pepper is combined with the user's password during Argon2id key derivation: `derived_key = Argon2id(password || pepper, salt, params)`.
        - **Pepper Rotation**: When rotating the pepper, create a new Secret Manager version, update `pepper_id` in new backups, and maintain old versions for decrypting existing backups until migrated.
    - **File Access Rate-Limiting**: Detailed specification below.

#### File Access Rate-Limiting Specification

To detect and prevent unauthorized bulk downloads or brute-force attempts:

**Signed URL Generation**:
- All access to `api_key_backup.json` MUST use **signed URLs** generated by the `generateBackupAccessUrl` Cloud Function (see Required Cloud Functions).
- Direct Storage access is blocked; Security Rules deny non-function access.
- The Cloud Function validates:
  1. `request.auth != null` (user is authenticated)
  2. `request.auth.uid == userId` (user owns the backup)
  3. Recent re-authentication within 5 minutes (`auth_time` check)

**TTL Enforcement**:
- Signed URLs expire after **5 minutes** (300 seconds).
- The signed URL includes `X-Goog-Expires: 300` and `X-Goog-SignedHeaders: host`.
- Server-side refresh policy: Users may request a new signed URL only after the previous one expires OR after a 60-second cooldown, whichever is longer.
- Example signed URL generation:
  ```javascript
  const [signedUrl] = await storage
    .bucket(bucketName)
    .file(`users/${userId}/api_key_backup.json`)
    .getSignedUrl({
      version: 'v4',
      action: 'read',
      expires: Date.now() + 5 * 60 * 1000, // 5 minutes
    });
  ```

**Anomaly Detection & Rate Limits**:
- **Per-user counters**: Track access attempts in Firestore (`access_audit/{userId}/backup_access`):
  ```json
  {
    "accessCount": "number",
    "windowStart": "timestamp",
    "lastAccess": "timestamp"
  }
  ```
- **Rate limits**:
  - Maximum **5 download requests per 15-minute window** per user.
  - Maximum **20 download requests per 24-hour window** per user.
  - Exceeding limits triggers a **30-minute cooldown** and alerts.
- **Alert triggers** (publish to Cloud Monitoring + Security team):
  - More than 3 failed decryption attempts within 10 minutes.
  - Access from a new geographic region or device fingerprint.
  - Access attempts during account lockout period.
- **Metrics**: Export to Cloud Monitoring for dashboards:
  - `backup_access_requests_total` (counter, labels: `userId`, `success`)
  - `backup_access_rate_limited` (counter, labels: `userId`)
  - `backup_access_suspicious` (counter, labels: `userId`, `reason`)

- **High-Risk Flow Alternative**: For users requiring enhanced security, an optional **server-side decryption flow** is available via the `decryptApiKeyMfa` Cloud Function. This function requires MFA verification, enforces server-side rate-limiting, logs all attempts to Cloud Audit Logs, and injects the server-side pepper from Secret Manager. See the `decryptApiKeyMfa` specification in Required Cloud Functions below for complete implementation details. This approach enables:
  - Server-controlled rate limits with account lockout (5 failed attempts = 1-hour lockout)
  - MFA verification before each decryption attempt
  - Comprehensive audit trails tied to auth identity
  - Centralized pepper management without client exposure
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
  "pepper_id": "string | null",
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

### 5. `getDecryptionPepper` (Callable)
- **Trigger**: `https.onCall` (Authenticated)
- **Purpose**: Securely retrieve the server-side pepper for client-side Argon2id key derivation.
- **Responsibilities**:
    - Verify `request.auth != null` and recent re-authentication (within 5 minutes).
    - Retrieve the pepper from Google Cloud Secret Manager using the `pepper_id` from the user's backup metadata.
    - Return the pepper value over TLS to the authenticated client.
    - Log access to Cloud Audit Logs with `userId`, timestamp, and `pepper_id`.
- **Security**:
    - Requires Firebase Authentication with recent sign-in.
    - Rate-limited: Maximum 10 requests per hour per user.
    - The pepper is transmitted but never logged in plaintext.
- **Request/Response**:
    ```typescript
    // Request
    { pepperId: string } // e.g., "projects/stylesync/secrets/api-key-pepper/versions/3"
    
    // Response
    { pepper: string } // base64-encoded pepper value
    ```
- **Touched Assets**: Google Cloud Secret Manager, Cloud Audit Logs.

### 6. `generateBackupAccessUrl` (Callable)
- **Trigger**: `https.onCall` (Authenticated)
- **Purpose**: Generate short-lived signed URLs for accessing `api_key_backup.json`.
- **Responsibilities**:
    - Verify `request.auth != null` and `request.auth.uid == userId`.
    - Verify recent re-authentication (within 5 minutes).
    - Check rate limits (5 requests per 15 minutes, 20 per 24 hours).
    - Generate a signed URL with 5-minute TTL.
    - Update access counters in `access_audit/{userId}/backup_access`.
    - Log request to Cloud Audit Logs.
- **Security**:
    - Enforces per-user rate limits with cooldown on violation.
    - Publishes alerts to Cloud Monitoring on suspicious patterns.
- **Request/Response**:
    ```typescript
    // Request
    { } // No parameters needed; userId from auth context
    
    // Response
    { 
      signedUrl: string,      // The signed URL (valid 5 minutes)
      expiresAt: string,      // ISO8601 expiration timestamp
      remainingRequests: number // Requests remaining in current window
    }
    ```
- **Touched Assets**: Firebase Storage, `access_audit` collection, Cloud Audit Logs, Cloud Monitoring.

### 7. `decryptApiKeyMfa` (Callable) — MFA-Protected Server-Side Decryption
- **Trigger**: `https.onCall` (Authenticated + MFA Required)
- **Purpose**: Optional high-security decryption flow that performs decryption server-side with MFA verification, rate-limiting, and comprehensive audit logging.
- **Endpoint Name**: `decryptApiKeyMfa`
- **Authentication Requirements**:
    - Firebase Authentication with verified email.
    - **MFA Verification Required**: The request must include a valid MFA assertion. Verify via `request.auth.token.firebase.sign_in_second_factor` or a custom MFA token.
    - Recent re-authentication within 5 minutes.
- **Rate-Limiting**:
    - Maximum **3 decryption attempts per 15-minute window**.
    - Maximum **10 decryption attempts per 24-hour window**.
    - **Account lockout**: After 5 consecutive failed attempts, lock decryption access for 1 hour.
    - Lockout state stored in `security_lockout/{userId}`:
      ```json
      {
        "failedAttempts": "number",
        "lockedUntil": "timestamp | null",
        "lastAttempt": "timestamp"
      }
      ```
- **Responsibilities**:
    1. Verify authentication, MFA, and re-authentication requirements.
    2. Check lockout status; reject if account is locked.
    3. Retrieve the encrypted backup from Storage.
    4. Retrieve the server-side pepper from Secret Manager (using `pepper_id` from backup).
    5. Derive the decryption key using Argon2id with the provided password hash and pepper.
    6. Decrypt the API key and return it to the client.
    7. On failure, increment `failedAttempts` and check lockout threshold.
    8. On success, reset `failedAttempts` to 0.
- **Audit Logging**:
    - Log ALL attempts (success and failure) to Cloud Audit Logs with:
      - `userId`, `timestamp`, `success: boolean`
      - `ipAddress` (from request headers)
      - `userAgent`, `geoLocation` (if available)
      - `mfaMethod` used (TOTP, SMS, etc.)
    - Publish security events to Cloud Monitoring:
      - `api_key_decrypt_attempt` (counter, labels: `success`, `mfaMethod`)
      - `api_key_decrypt_lockout` (counter)
- **Security**:
    - The plaintext API key is returned over TLS and NEVER logged.
    - The user's password is never sent to the server; only a client-side hash is transmitted.
    - The pepper is injected server-side and never exposed to the client in this flow.
- **Request/Response**:
    ```typescript
    // Request
    {
      passwordHash: string,    // Client-side SHA-256 of password (NOT plaintext)
      mfaToken: string         // MFA verification token/assertion
    }
    
    // Response (success)
    {
      apiKey: string,          // Decrypted API key
      decryptedAt: string      // ISO8601 timestamp
    }
    
    // Response (failure)
    {
      error: string,           // "INVALID_PASSWORD" | "MFA_REQUIRED" | "ACCOUNT_LOCKED" | "RATE_LIMITED"
      lockedUntil?: string,    // ISO8601 timestamp if locked
      remainingAttempts?: number
    }
    ```
- **Touched Assets**: Firebase Storage, Google Cloud Secret Manager, `security_lockout` collection, Cloud Audit Logs, Cloud Monitoring.
- **Cross-Reference**: This function implements the "High-Risk Flow Alternative" described in the API Key Backup Mitigation Policies section above.

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

