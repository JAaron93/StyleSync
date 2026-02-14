# Cloud Backup Integration

<cite>
**Referenced Files in This Document**
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart)
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart)
- [cloud_backup_blob.dart](file://lib/core/byok/models/cloud_backup_blob.dart)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart)
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart)
- [secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart)
- [byok_storage_keys.dart](file://lib/core/byok/byok_storage_keys.dart)
- [byok_error.dart](file://lib/core/byok/models/byok_error.dart)
- [api_key_config.dart](file://lib/core/byok/models/api_key_config.dart)
- [cloud_backup_service_test.dart](file://test/cloud_backup_service_test.dart)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Detailed Component Analysis](#detailed-component-analysis)
6. [Dependency Analysis](#dependency-analysis)
7. [Performance Considerations](#performance-considerations)
8. [Troubleshooting Guide](#troubleshooting-guide)
9. [Conclusion](#conclusion)

## Introduction
This document provides comprehensive technical documentation for the cloud backup integration capabilities in the StyleSync application. It focuses on four primary methods: `enableCloudBackup`, `disableCloudBackup`, `restoreFromCloudBackup`, and `rotateBackupPassphrase`. The documentation explains the passphrase-based encryption workflow, backup creation and management processes, and the relationship between local configuration and cloud storage. It also details error handling strategies for cloud operations, including partial failure recovery and state consistency maintenance, along with practical examples and security considerations.

## Project Structure
The cloud backup integration spans several core modules:
- Cloud backup service: Implements the complete backup lifecycle using Firebase Storage, encryption, and key derivation
- BYOK manager: Orchestrates API key lifecycle and coordinates cloud backup operations
- Cryptographic services: Provides encryption and key derivation functionality
- Secure storage: Manages local persistence of API key configurations and backup flags
- Models: Define data structures for API key configurations and backup blobs

```mermaid
graph TB
subgraph "Application Layer"
BYOKManager["BYOKManager<br/>API key lifecycle orchestration"]
end
subgraph "Cloud Integration"
CloudBackupService["CloudBackupService<br/>Firebase Storage operations"]
FirebaseStorage["Firebase Storage<br/>Remote cloud storage"]
end
subgraph "Security Layer"
EncryptionService["EncryptionService<br/>AES-GCM encryption"]
KeyDerivationService["KeyDerivationService<br/>KDF with Argon2/PBKDF2"]
CloudBackupBlob["CloudBackupBlob<br/>Encrypted backup structure"]
end
subgraph "Local Persistence"
SecureStorage["SecureStorageService<br/>Hardware/software-backed storage"]
APIKeyConfig["APIKeyConfig<br/>API key configuration"]
end
BYOKManager --> CloudBackupService
BYOKManager --> SecureStorage
CloudBackupService --> FirebaseStorage
CloudBackupService --> EncryptionService
CloudBackupService --> KeyDerivationService
CloudBackupService --> CloudBackupBlob
SecureStorage --> APIKeyConfig
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L149-L583)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L97-L899)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L22-L75)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L17-L118)
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L11-L30)

**Section sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L1-L583)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L1-L900)

## Core Components
This section documents the four primary cloud backup methods and their implementation details.

### enableCloudBackup Method
The `enableCloudBackup` method enables cloud backup for the current API key configuration. It performs the following steps:
1. Validates that the CloudBackupService is available
2. Retrieves the current API key configuration
3. Creates or updates the encrypted backup in cloud storage
4. Updates local configuration to mark cloud backup as enabled
5. Stores the cloud backup enabled flag

```mermaid
sequenceDiagram
participant Client as "Client Application"
participant BYOK as "BYOKManager"
participant Cloud as "CloudBackupService"
participant Storage as "SecureStorageService"
participant Firebase as "Firebase Storage"
Client->>BYOK : enableCloudBackup(passphrase)
BYOK->>BYOK : validate CloudBackupService availability
BYOK->>BYOK : getAPIKey()
BYOK->>Cloud : createOrUpdateBackup(config, passphrase)
Cloud->>Cloud : deriveKey(passphrase, metadata)
Cloud->>Cloud : encrypt(config, key)
Cloud->>Firebase : upload encrypted backup
Cloud-->>BYOK : Success/Failure
BYOK->>Storage : write apiKeyConfig (mark enabled)
BYOK->>Storage : write cloudBackupEnabled=true
BYOK-->>Client : Success/Failure
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L387-L429)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L167-L249)

### disableCloudBackup Method
The `disableCloudBackup` method disables cloud backup and optionally deletes the remote backup:
1. Updates local configuration to mark cloud backup as disabled
2. Removes cloud backup enabled flag and passphrase hash
3. Optionally deletes the backup from cloud storage
4. Logs any storage errors without failing the operation

```mermaid
flowchart TD
Start([disableCloudBackup Called]) --> GetConfig["Get current API key config"]
GetConfig --> UpdateLocal["Update local config<br/>cloudBackupEnabled=false"]
UpdateLocal --> RemoveFlags["Remove cloud backup flags<br/>from secure storage"]
RemoveFlags --> CheckDelete{"deleteBackup parameter?"}
CheckDelete --> |Yes| DeleteCloud["Delete backup from cloud storage"]
CheckDelete --> |No| SkipDelete["Skip cloud deletion"]
DeleteCloud --> LogError{"Deletion failed?"}
LogError --> |Yes| LogWarning["Log warning but continue"]
LogError --> |No| Continue["Continue"]
SkipDelete --> Continue
LogWarning --> Continue
Continue --> End([Operation Complete])
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L432-L466)

### restoreFromCloudBackup Method
The `restoreFromCloudBackup` method restores an API key configuration from cloud backup:
1. Validates CloudBackupService availability
2. Calls cloud service to restore backup using passphrase
3. Decrypts and validates the restored configuration
4. Stores the restored configuration locally
5. Updates cloud backup enabled flag if present in restored config

```mermaid
sequenceDiagram
participant Client as "Client Application"
participant BYOK as "BYOKManager"
participant Cloud as "CloudBackupService"
participant Storage as "SecureStorageService"
Client->>BYOK : restoreFromCloudBackup(passphrase)
BYOK->>BYOK : validate CloudBackupService availability
BYOK->>Cloud : restoreBackup(passphrase)
Cloud->>Cloud : download encrypted backup
Cloud->>Cloud : deriveKey(passphrase, metadata)
Cloud->>Cloud : decrypt(encryptedData)
Cloud-->>BYOK : APIKeyConfig
BYOK->>Storage : write apiKeyConfig
BYOK->>Storage : write cloudBackupEnabled (if enabled)
BYOK-->>Client : APIKeyConfig
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L469-L502)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L252-L317)

### rotateBackupPassphrase Method
The `rotateBackupPassphrase` method securely rotates the passphrase for an existing backup using a temporary backup approach:
1. Captures original createdAt timestamp
2. Restores backup with old passphrase
3. Uploads re-encrypted backup to temporary path
4. Verifies temp backup can be decrypted with new passphrase
5. Performs atomic swap: delete old backup, upload temp to final
6. Cleans up temporary backup

```mermaid
flowchart TD
Start([rotateBackupPassphrase Called]) --> ValidateUser["Validate authenticated user"]
ValidateUser --> GetExisting["Fetch existing backup blob"]
GetExisting --> SaveTimestamp["Save original createdAt timestamp"]
SaveTimestamp --> RestoreOld["Restore backup with old passphrase"]
RestoreOld --> UploadTemp["Upload re-encrypted to temp path"]
UploadTemp --> VerifyTemp["Verify temp backup with new passphrase"]
VerifyTemp --> VerifySuccess{"Verification success?"}
VerifySuccess --> |No| CleanupTemp["Delete temp backup<br/>Return error"]
VerifySuccess --> |Yes| DeleteOriginal["Delete original backup"]
DeleteOriginal --> UploadFinal["Upload to final path<br/>preserve createdAt"]
UploadFinal --> FinalSuccess{"Upload success?"}
FinalSuccess --> |No| CriticalError["Critical: Original deleted,<br/>new upload failed<br/>Preserve temp for recovery"]
FinalSuccess --> |Yes| CleanupTemp2["Delete temp backup"]
CleanupTemp2 --> Success([Success])
CleanupTemp --> Success
CriticalError --> Success
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L527-L541)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L414-L555)

**Section sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L117-L146)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L35-L91)

## Architecture Overview
The cloud backup architecture follows a layered approach with clear separation of concerns:

```mermaid
classDiagram
class BYOKManager {
+storeAPIKey(apiKey, projectId) Result~void~
+getAPIKey() Result~APIKeyConfig~
+deleteAPIKey(deleteCloudBackup) Result~void~
+updateAPIKey(newApiKey, projectId, passphrase) Result~void~
+enableCloudBackup(passphrase) Result~void~
+disableCloudBackup(deleteBackup) Result~void~
+restoreFromCloudBackup(passphrase) Result~APIKeyConfig~
+isCloudBackupEnabled() bool
+rotateBackupPassphrase(oldPassphrase, newPassphrase) Result~void~
}
class CloudBackupService {
+createOrUpdateBackup(config, passphrase, createdAt) Result~void~
+restoreBackup(passphrase) Result~APIKeyConfig~
+deleteBackup() Result~void~
+backupExists() Result~bool~
+rotatePassphrase(oldPassphrase, newPassphrase) Result~void~
+verifyPassphrase(passphrase) Result~bool~
}
class CloudBackupServiceImpl {
-FirebaseStorage _storage
-FirebaseAuth _auth
-KeyDerivationService _keyDerivationService
-EncryptionService _encryptionService
+createOrUpdateBackup(config, passphrase, createdAt)
+restoreBackup(passphrase)
+deleteBackup()
+backupExists()
+rotatePassphrase(oldPassphrase, newPassphrase)
+verifyPassphrase(passphrase)
}
class EncryptionService {
+encrypt(data, key) Uint8List
+decrypt(encryptedData, key) Uint8List
}
class KeyDerivationService {
+deriveKey(passphrase, metadata) Uint8List
+generateMetadata() KdfMetadata
}
class SecureStorageService {
+write(key, value) void
+read(key) String?
+delete(key) void
+deleteAll() void
}
BYOKManager --> CloudBackupService : "orchestrates"
CloudBackupService <|.. CloudBackupServiceImpl : "implements"
CloudBackupServiceImpl --> EncryptionService : "uses"
CloudBackupServiceImpl --> KeyDerivationService : "uses"
BYOKManager --> SecureStorageService : "uses"
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L84-L147)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L21-L91)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L14-L20)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L9-L15)
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L11-L29)

## Detailed Component Analysis

### Passphrase-Based Encryption Workflow
The encryption workflow uses a hybrid approach combining key derivation and symmetric encryption:

```mermaid
flowchart TD
Input([User Passphrase]) --> GenerateMetadata["Generate KDF Metadata<br/>with random salt"]
GenerateMetadata --> DeriveKey["Derive 32-byte key<br/>using Argon2id/PBKDF2"]
DeriveKey --> SerializeConfig["Serialize APIKeyConfig to JSON"]
SerializeConfig --> Encrypt["Encrypt with AES-GCM<br/>nonce + ciphertext + MAC"]
Encrypt --> CreateBlob["Create CloudBackupBlob<br/>with KDF metadata"]
CreateBlob --> Upload["Upload to Firebase Storage"]
Upload --> DecryptPath["Decryption Path"]
DecryptPath --> DeriveKey2["Derive same key<br/>from passphrase + metadata"]
DeriveKey2 --> Decrypt2["Decrypt AES-GCM<br/>verify MAC"]
Decrypt2 --> ParseConfig["Parse APIKeyConfig JSON"]
ParseConfig --> Output([Restored API Key Config])
```

**Diagram sources**
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L181-L211)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L22-L75)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L22-L53)

### Backup Creation and Management
The backup creation process involves several critical steps:

1. **Authentication Verification**: Ensures user is authenticated before any operations
2. **KDF Metadata Generation**: Creates fresh salt and parameters for key derivation
3. **Key Derivation**: Uses Argon2id on mobile devices and PBKDF2 on desktop/web
4. **Encryption**: Encrypts serialized configuration with AES-GCM
5. **Blob Creation**: Constructs CloudBackupBlob with version, metadata, and timestamps
6. **Upload**: Stores encrypted data in Firebase Storage

### Error Handling Strategies
The system implements comprehensive error handling with distinct error types:

```mermaid
flowchart TD
Operation([Cloud Operation]) --> TryOp["Execute operation"]
TryOp --> Success{"Success?"}
Success --> |Yes| ReturnSuccess["Return Success"]
Success --> |No| CheckError["Check error type"]
CheckError --> NetworkError{"Network error?"}
NetworkError --> |Yes| ReturnNetwork["Return BackupErrorType.networkError"]
NetworkError --> |No| CheckStorage{"Storage error?"}
CheckStorage --> |Yes| ReturnStorage["Return BackupErrorType.storageError"]
CheckStorage --> |No| CheckAuth{"Authentication error?"}
CheckAuth --> |Yes| ReturnAuth["Return BackupErrorType.storageError"]
CheckAuth --> |No| CheckCorrupt{"Data corruption?"}
CheckCorrupt --> |Yes| ReturnCorrupt["Return BackupErrorType.corrupted"]
CheckCorrupt --> |No| ReturnOther["Return BackupErrorType.storageError"]
```

**Diagram sources**
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L139-L164)
- [byok_error.dart](file://lib/core/byok/models/byok_error.dart#L68-L83)

### State Consistency Maintenance
The system maintains state consistency through careful transaction-like operations:

1. **Atomic Operations**: Methods are designed to minimize inconsistent states
2. **Temporary Backups**: Used during passphrase rotation to prevent data loss
3. **Error Recovery**: Temporary backups serve as recovery points
4. **Local State Updates**: Local configuration is updated before cloud operations when safe

**Section sources**
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L414-L555)
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L387-L541)

## Dependency Analysis
The cloud backup system has well-defined dependencies that support modularity and testability:

```mermaid
graph TB
subgraph "External Dependencies"
FirebaseAuth["Firebase Auth"]
FirebaseStorage["Firebase Storage"]
Argon2["Argon2 Library"]
Crypto["Cryptography Library"]
FlutterSecureStorage["Flutter Secure Storage"]
end
subgraph "Internal Dependencies"
BYOKManager["BYOKManager"]
CloudBackupService["CloudBackupService"]
EncryptionService["EncryptionService"]
KeyDerivationService["KeyDerivationService"]
SecureStorageService["SecureStorageService"]
end
BYOKManager --> CloudBackupService
CloudBackupService --> FirebaseAuth
CloudBackupService --> FirebaseStorage
CloudBackupService --> EncryptionService
CloudBackupService --> KeyDerivationService
BYOKManager --> SecureStorageService
EncryptionService --> Crypto
KeyDerivationService --> Argon2
SecureStorageService --> FlutterSecureStorage
```

**Diagram sources**
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L5-L14)
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L1-L15)

**Section sources**
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L1-L15)
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L1-L15)

## Performance Considerations
Several performance optimizations are implemented:

1. **Platform-Specific KDF**: Uses Argon2id on mobile devices (hardware acceleration) and PBKDF2 on desktop/web
2. **Asynchronous Operations**: All cryptographic operations use `compute()` for CPU-intensive tasks
3. **Efficient Serialization**: JSON serialization minimizes overhead
4. **Network Optimization**: Temporary backup approach reduces network round trips
5. **Memory Management**: Proper disposal of sensitive data after operations

## Troubleshooting Guide

### Common Error Scenarios and Solutions

#### Authentication Failures
- **Symptoms**: `BackupErrorType.storageError` with authentication messages
- **Causes**: User not logged in, session expired
- **Solutions**: Re-authenticate user, check Firebase Auth state

#### Network Connectivity Issues
- **Symptoms**: `BackupErrorType.networkError` during operations
- **Causes**: Internet connectivity, DNS failures, server timeouts
- **Solutions**: Retry operations, implement exponential backoff, check firewall settings

#### Passphrase Verification Failures
- **Symptoms**: `BackupErrorType.wrongPassphrase` during restore/rotation
- **Causes**: Incorrect passphrase, corrupted backup
- **Solutions**: Verify passphrase accuracy, check backup integrity

#### Partial Failure Recovery
During passphrase rotation, if failures occur:
1. **Original backup deleted, new upload failed**: Temp backup remains at temp path
2. **Verification failed**: Temp backup is cleaned up automatically
3. **Network interruption**: Resume rotation using temp backup

### Practical Examples

#### Enable Cloud Backup Flow
```mermaid
sequenceDiagram
participant User as "User"
participant BYOK as "BYOKManager"
participant Cloud as "CloudBackupService"
participant Storage as "SecureStorageService"
User->>BYOK : enableCloudBackup("my-secret-passphrase")
BYOK->>BYOK : validate existing API key
BYOK->>Cloud : createOrUpdateBackup(config, "passphrase")
Cloud->>Cloud : encrypt + upload
Cloud-->>BYOK : success
BYOK->>Storage : update local config (enabled=true)
BYOK-->>User : success
```

#### Restore Backup Procedure
```mermaid
flowchart TD
Start([Restore Backup]) --> ValidateService["Validate CloudBackupService"]
ValidateService --> CallRestore["Call restoreBackup(passphrase)"]
CallRestore --> DownloadBlob["Download encrypted blob"]
DownloadBlob --> DeriveKey["Derive key from passphrase"]
DeriveKey --> DecryptData["Decrypt with AES-GCM"]
DecryptData --> ParseJSON["Parse APIKeyConfig JSON"]
ParseJSON --> StoreLocal["Store locally"]
StoreLocal --> UpdateFlags["Update cloud backup flags"]
UpdateFlags --> Complete([Complete])
```

#### Passphrase Rotation Process
```mermaid
flowchart TD
Start([Rotate Passphrase]) --> CaptureTimestamp["Capture original createdAt"]
CaptureTimestamp --> RestoreBackup["Restore with old passphrase"]
RestoreBackup --> UploadTemp["Upload re-encrypted to temp"]
UploadTemp --> VerifyTemp["Verify temp with new passphrase"]
VerifyTemp --> VerifySuccess{"Verification success?"}
VerifySuccess --> |No| CleanupTemp["Cleanup temp & error"]
VerifySuccess --> |Yes| DeleteOriginal["Delete original backup"]
DeleteOriginal --> UploadFinal["Upload to final path"]
UploadFinal --> CleanupTemp2["Cleanup temp"]
CleanupTemp2 --> Success([Success])
```

**Section sources**
- [cloud_backup_service_test.dart](file://test/cloud_backup_service_test.dart#L323-L371)
- [byok_error.dart](file://lib/core/byok/models/byok_error.dart#L57-L83)

## Security Considerations

### Cryptographic Implementation
1. **Key Derivation**: Uses Argon2id (mobile) and PBKDF2 (desktop/web) with random salts
2. **Encryption**: AES-GCM provides authenticated encryption with MAC verification
3. **Key Size**: 256-bit keys for AES-GCM encryption
4. **Nonce Management**: Automatic nonce generation prevents replay attacks

### Data Protection Measures
1. **Local Storage**: Hardware-backed secure storage on supported platforms
2. **Network Security**: HTTPS encryption for all cloud communications
3. **Passphrase Handling**: No plaintext passphrase storage
4. **Temporary Backups**: Minimizes exposure window during rotation

### Privacy and Compliance
1. **Client-Side Encryption**: Keys never leave device boundaries
2. **Minimal Data Collection**: Only encrypted backup data stored remotely
3. **Data Retention**: Explicit deletion capabilities for user control
4. **Audit Logging**: Comprehensive error logging for security monitoring

### Integration Patterns with CloudBackupService
The CloudBackupService follows these integration patterns:
1. **Riverpod Providers**: Dependency injection for testability and mocking
2. **Result Type Pattern**: Consistent error handling across all operations
3. **Provider Architecture**: Modular design enabling easy testing and extension
4. **Platform Abstraction**: Cross-platform compatibility with platform-specific optimizations

**Section sources**
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L6-L12)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L27-L32)
- [secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart#L37-L62)