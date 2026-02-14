# BYOK Manager

<cite>
**Referenced Files in This Document**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart)
- [byok_error.dart](file://lib/core/byok/models/byok_error.dart)
- [validation_result.dart](file://lib/core/byok/models/validation_result.dart)
- [api_key_config.dart](file://lib/core/byok/models/api_key_config.dart)
- [cloud_backup_blob.dart](file://lib/core/byok/models/cloud_backup_blob.dart)
- [byok_storage_keys.dart](file://lib/core/byok/byok_storage_keys.dart)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart)
- [api_key_validator.dart](file://lib/core/byok/api_key_validator.dart)
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart)
- [kdf_metadata.dart](file://lib/core/crypto/kdf_metadata.dart)
- [byok_manager_test.dart](file://test/byok_manager_test.dart)
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
10. [Appendices](#appendices)

## Introduction
The BYOK (Bring Your Own Key) Manager service is the central orchestrator for API key lifecycle management in the application. It securely stores, retrieves, validates, updates, and deletes user-provided Vertex AI API keys, and integrates with cloud backup for disaster recovery. The service enforces robust error handling via a Result<T> sealed class pattern, supports idempotency keys, preserves metadata across updates, and provides passphrase rotation capabilities for cloud backups.

## Project Structure
The BYOK module is organized around a clear separation of concerns:
- Core orchestration: BYOKManager interface and its default implementation BYOKManagerImpl
- Domain models: APIKeyConfig, ValidationResult, BYOKError, CloudBackupBlob
- Validation: APIKeyValidator for format and functional checks
- Storage: SecureStorageService abstraction and BYOKStorageKeys constants
- Cloud backup: CloudBackupService abstraction and CloudBackupServiceImpl
- Cryptography: Key derivation and encryption services for secure cloud backups
- Tests: Comprehensive unit tests validating workflows and error handling

```mermaid
graph TB
subgraph "BYOK Orchestration"
BYOKMgr["BYOKManager<br/>Interface"]
BYOKImpl["BYOKManagerImpl<br/>Implementation"]
end
subgraph "Domain Models"
APIKeyConfig["APIKeyConfig"]
ValidationResult["ValidationResult<br/>(Success/Failure)"]
BYOKError["BYOKError<br/>(ValidationError/NotFoundError/StorageError/BackupError/CryptoError)"]
CloudBackupBlob["CloudBackupBlob"]
end
subgraph "Validation & Storage"
Validator["APIKeyValidator"]
Storage["SecureStorageService"]
Keys["BYOKStorageKeys"]
end
subgraph "Cloud Backup"
CBService["CloudBackupService"]
CBImpl["CloudBackupServiceImpl"]
end
subgraph "Cryptography"
KDF["KeyDerivationService"]
ENC["EncryptionService"]
KDFMeta["KdfMetadata"]
end
BYOKMgr --> BYOKImpl
BYOKImpl --> Validator
BYOKImpl --> Storage
BYOKImpl --> CBService
BYOKImpl --> Keys
CBService --> CBImpl
CBImpl --> KDF
CBImpl --> ENC
CBImpl --> KDFMeta
BYOKImpl --> APIKeyConfig
BYOKImpl --> ValidationResult
BYOKImpl --> BYOKError
BYOKImpl --> CloudBackupBlob
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L84-L147)
- [api_key_validator.dart](file://lib/core/byok/api_key_validator.dart#L14-L48)
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L11-L29)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L21-L91)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L14-L20)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L9-L15)
- [kdf_metadata.dart](file://lib/core/crypto/kdf_metadata.dart#L9-L22)
- [api_key_config.dart](file://lib/core/byok/models/api_key_config.dart#L5-L32)
- [validation_result.dart](file://lib/core/byok/models/validation_result.dart#L5-L7)
- [byok_error.dart](file://lib/core/byok/models/byok_error.dart#L7-L15)
- [cloud_backup_blob.dart](file://lib/core/byok/models/cloud_backup_blob.dart#L8-L38)

**Section sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L1-L583)
- [api_key_validator.dart](file://lib/core/byok/api_key_validator.dart#L1-L322)
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L1-L30)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L1-L900)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L1-L75)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L1-L118)
- [kdf_metadata.dart](file://lib/core/crypto/kdf_metadata.dart#L1-L78)
- [api_key_config.dart](file://lib/core/byok/models/api_key_config.dart#L1-L110)
- [validation_result.dart](file://lib/core/byok/models/validation_result.dart#L1-L188)
- [byok_error.dart](file://lib/core/byok/models/byok_error.dart#L1-L94)
- [cloud_backup_blob.dart](file://lib/core/byok/models/cloud_backup_blob.dart#L1-L157)

## Core Components
- BYOKManager: Abstract interface defining the API key lifecycle operations (store, get, delete, update, enable/disable cloud backup, restore, passphrase rotation, presence checks).
- BYOKManagerImpl: Default implementation orchestrating validation, secure storage, and cloud backup operations.
- Result<T> sealed class: Standardized success/failure pattern with helpers for mapping and async transformations.
- APIKeyConfig: Immutable model capturing the API key, project ID, timestamps, cloud backup state, and idempotency key.
- APIKeyValidator: Validates key format and functionality via a real Vertex AI API call.
- SecureStorageService: Abstraction for platform-native secure storage.
- CloudBackupService: Abstraction for encrypted cloud backup operations using client-side encryption.
- CloudBackupServiceImpl: Implements cloud backup with Argon2id/PBKDF2 key derivation and AES-GCM encryption.
- BYOKError and ValidationResult: Hierarchies for precise error reporting and validation outcomes.

**Section sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L84-L147)
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L153-L549)
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L23-L78)
- [api_key_config.dart](file://lib/core/byok/models/api_key_config.dart#L5-L110)
- [api_key_validator.dart](file://lib/core/byok/api_key_validator.dart#L14-L48)
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L11-L29)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L21-L91)
- [byok_error.dart](file://lib/core/byok/models/byok_error.dart#L7-L94)
- [validation_result.dart](file://lib/core/byok/models/validation_result.dart#L5-L188)

## Architecture Overview
The BYOK Manager coordinates between local secure storage, API key validation, and optional cloud backup. It ensures that:
- API keys are validated before storage
- Local metadata is preserved across updates
- Cloud backup is optional and encrypted client-side
- Errors are handled gracefully with clear error types

```mermaid
sequenceDiagram
participant Client as "Caller"
participant BYOK as "BYOKManagerImpl"
participant Val as "APIKeyValidator"
participant Store as "SecureStorageService"
participant CB as "CloudBackupService"
Client->>BYOK : storeAPIKey(apiKey, projectId)
BYOK->>Val : validateFormat(apiKey)
Val-->>BYOK : ValidationResult
alt ValidationFailure
BYOK-->>Client : Failure(ValidationError)
else ValidationSuccess
BYOK->>Val : validateFunctionality(apiKey, projectId)
Val-->>BYOK : ValidationResult
alt ValidationFailure
BYOK-->>Client : Failure(ValidationError)
else ValidationSuccess
BYOK->>Store : write(apiKeyConfig)
Store-->>BYOK : ok
BYOK-->>Client : Success(void)
end
end
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L182-L231)
- [api_key_validator.dart](file://lib/core/byok/api_key_validator.dart#L14-L48)
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L12-L19)

**Section sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L182-L231)
- [api_key_validator.dart](file://lib/core/byok/api_key_validator.dart#L14-L48)
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L12-L19)

## Detailed Component Analysis

### BYOKManager and BYOKManagerImpl
- Responsibilities:
  - Validate API key format and functionality
  - Persist API key configuration with metadata
  - Manage cloud backup enablement and restoration
  - Update keys while preserving metadata and optionally re-encrypting backups
  - Provide presence checks and passphrase rotation
- Key behaviors:
  - Idempotency key generation for deduplication
  - Metadata preservation during updates (createdAt, lastValidated, cloudBackupEnabled)
  - Graceful fallback when cloud backup re-encryption fails (disables backup locally)
  - Optional deletion of cloud backup during key deletion

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
+hasStoredKey() Future~bool~
+isCloudBackupEnabled() Future~bool~
+rotateBackupPassphrase(oldPassphrase, newPassphrase) Result~void~
}
class BYOKManagerImpl {
-SecureStorageService _secureStorage
-APIKeyValidator _apiKeyValidator
-CloudBackupService? _cloudBackupService
-Uuid _uuid
+storeAPIKey(...)
+getAPIKey()
+deleteAPIKey(...)
+updateAPIKey(...)
+enableCloudBackup(...)
+disableCloudBackup(...)
+restoreFromCloudBackup(...)
+hasStoredKey()
+isCloudBackupEnabled()
+rotateBackupPassphrase(...)
-_generateIdempotencyKey() String
}
BYOKManager <|.. BYOKManagerImpl
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L84-L147)
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L153-L549)

**Section sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L153-L549)

### Result<T> Sealed Class Pattern
- Success<T>: Holds a successful value
- Failure<T>: Holds a BYOKError
- Helpers:
  - isSuccess/isFailure getters
  - valueOrNull/errorOrNull accessors
  - map/mapAsync for transforming success values

```mermaid
classDiagram
class Result~T~ {
<<sealed>>
+isSuccess bool
+isFailure bool
+valueOrNull T?
+errorOrNull BYOKError?
+map<U>(transform) Result~U~
+mapAsync<U>(transform) Future~Result~U~~
}
class Success~T~ {
+value T
+toString() String
}
class Failure~T~ {
+error BYOKError
+toString() String
}
Result~T~ <|-- Success~T~
Result~T~ <|-- Failure~T~
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L23-L78)

**Section sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L23-L78)

### APIKeyConfig Model
- Fields: apiKey, projectId, createdAt, lastValidated, cloudBackupEnabled, idempotencyKey
- Methods: toJson/fromJson, copyWith, equality/hashCode, toString
- Purpose: Encapsulates the persisted API key configuration with metadata

**Section sources**
- [api_key_config.dart](file://lib/core/byok/models/api_key_config.dart#L5-L110)

### ValidationResult and BYOKError
- ValidationResult: Sealed class with ValidationSuccess and ValidationFailure
  - ValidationSuccess: Optional metadata (e.g., available models)
  - ValidationFailure: Type, message, optional errorCode/originalError
- BYOKError: Sealed class hierarchy for all error types
  - ValidationError: wraps ValidationResult
  - NotFoundError: no key stored
  - StorageError: storage failures
  - BackupError: cloud backup failures with typed reasons
  - CryptoError: encryption/decryption failures

```mermaid
classDiagram
class ValidationResult {
<<sealed>>
}
class ValidationSuccess {
+metadata Map~String,dynamic~?
}
class ValidationFailure {
+type ValidationFailureType
+message String
+errorCode String?
+originalError Object?
}
ValidationResult <|-- ValidationSuccess
ValidationResult <|-- ValidationFailure
class BYOKError {
<<sealed>>
+message String
+originalError Object?
}
class ValidationError {
+validationResult ValidationResult
}
class NotFoundError
class StorageError
class BackupError {
+type BackupErrorType
}
class CryptoError
BYOKError <|-- ValidationError
BYOKError <|-- NotFoundError
BYOKError <|-- StorageError
BYOKError <|-- BackupError
BYOKError <|-- CryptoError
```

**Diagram sources**
- [validation_result.dart](file://lib/core/byok/models/validation_result.dart#L5-L188)
- [byok_error.dart](file://lib/core/byok/models/byok_error.dart#L7-L94)

**Section sources**
- [validation_result.dart](file://lib/core/byok/models/validation_result.dart#L5-L188)
- [byok_error.dart](file://lib/core/byok/models/byok_error.dart#L7-L94)

### CloudBackupBlob
- Fields: version, kdfMetadata, encryptedData, createdAt, updatedAt
- Methods: toJson/fromJson, copyWith, equality/hashCode, toString
- Purpose: Serialized encrypted backup container for cloud storage

**Section sources**
- [cloud_backup_blob.dart](file://lib/core/byok/models/cloud_backup_blob.dart#L8-L157)

### CloudBackupService and CloudBackupServiceImpl
- CloudBackupService: Abstract interface for create/update/restore/delete/exists/rotate/verify
- CloudBackupServiceImpl: Implements encryption using AES-GCM, key derivation using Argon2id/PBKDF2, and storage via Firebase Storage
- Passphrase rotation uses a temporary backup to achieve atomic swap

```mermaid
sequenceDiagram
participant BYOK as "BYOKManagerImpl"
participant CBS as "CloudBackupService"
participant KDF as "KeyDerivationService"
participant ENC as "EncryptionService"
participant FS as "Firebase Storage"
BYOK->>CBS : createOrUpdateBackup(config, passphrase)
CBS->>KDF : generateMetadata()
KDF-->>CBS : KdfMetadata
CBS->>KDF : deriveKey(passphrase, metadata)
KDF-->>CBS : key
CBS->>ENC : encrypt(configJson, key)
ENC-->>CBS : encryptedData
CBS->>FS : putString(blobJson)
FS-->>CBS : ok
CBS-->>BYOK : Success(void)
```

**Diagram sources**
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L35-L249)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L36-L53)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L26-L40)

**Section sources**
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L21-L91)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L167-L249)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L9-L15)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L14-L20)

### APIKeyValidator
- Validates format (prefix, length, characters)
- Validates functionality by calling Vertex AI models endpoint
- Supports configurable timeout and injectable HTTP client

**Section sources**
- [api_key_validator.dart](file://lib/core/byok/api_key_validator.dart#L14-L48)
- [api_key_validator.dart](file://lib/core/byok/api_key_validator.dart#L112-L150)
- [api_key_validator.dart](file://lib/core/byok/api_key_validator.dart#L153-L224)

### SecureStorageService and BYOKStorageKeys
- SecureStorageService: Abstraction for write/read/delete/deleteAll/backend detection
- BYOKStorageKeys: Constants for storage keys (apiKeyConfig, backupPassphraseHash, cloudBackupEnabled)

**Section sources**
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L11-L29)
- [byok_storage_keys.dart](file://lib/core/byok/byok_storage_keys.dart#L5-L14)

### Complete API Key Workflow
- Validation: Format check followed by functional check
- Storage: Serialize APIKeyConfig and write to secure storage
- Cloud backup: Optional, encrypted, and stored separately
- Update: Validate new key, preserve metadata, optionally re-encrypt backup
- Restore: Download and decrypt backup, then store locally
- Deletion: Remove local config and optionally cloud backup

```mermaid
flowchart TD
Start(["Operation Entry"]) --> ValidateFormat["Validate Format"]
ValidateFormat --> FormatValid{"Format Valid?"}
FormatValid --> |No| ReturnFormatError["Return ValidationError"]
FormatValid --> |Yes| ValidateFunc["Validate Functionality"]
ValidateFunc --> FuncValid{"Functionality Valid?"}
FuncValid --> |No| ReturnFuncError["Return ValidationError"]
FuncValid --> |Yes| BuildConfig["Build APIKeyConfig<br/>with metadata"]
BuildConfig --> StoreLocal["Store in Secure Storage"]
StoreLocal --> CloudOpt{"Cloud Backup Enabled?"}
CloudOpt --> |Yes| UploadBackup["Upload Encrypted Backup"]
CloudOpt --> |No| Done["Done"]
UploadBackup --> Done
ReturnFormatError --> Done
ReturnFuncError --> Done
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L182-L231)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L167-L249)

**Section sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L182-L231)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L167-L249)

## Dependency Analysis
- BYOKManagerImpl depends on:
  - SecureStorageService for persistence
  - APIKeyValidator for validation
  - CloudBackupService for optional cloud backup
  - Uuid for idempotency key generation
- CloudBackupServiceImpl depends on:
  - KeyDerivationService for key derivation
  - EncryptionService for encryption/decryption
  - Firebase Storage for cloud operations
- APIKeyValidator depends on:
  - HTTP client for functional validation
- Cryptographic services depend on:
  - Argon2 and PBKDF2 for key derivation
  - AES-GCM for encryption

```mermaid
graph LR
BYOK["BYOKManagerImpl"] --> S["SecureStorageService"]
BYOK --> V["APIKeyValidator"]
BYOK --> CBS["CloudBackupService"]
BYOK --> U["Uuid"]
CBS --> KDF["KeyDerivationService"]
CBS --> ENC["EncryptionService"]
CBS --> FS["Firebase Storage"]
V --> HTTP["HTTP Client"]
KDF --> ARG["Argon2/PBKDF2"]
ENC --> AES["AES-GCM"]
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L153-L180)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L97-L119)
- [api_key_validator.dart](file://lib/core/byok/api_key_validator.dart#L53-L80)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L17-L21)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L22-L23)

**Section sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L153-L180)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L97-L119)
- [api_key_validator.dart](file://lib/core/byok/api_key_validator.dart#L53-L80)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L17-L21)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L22-L23)

## Performance Considerations
- Validation overhead: Functional validation performs a network request; cache results when feasible within session boundaries.
- Cloud backup latency: Encryption and upload can be slow; consider background operations and progress feedback.
- Key derivation cost: Argon2id/PBKDF2 parameters vary by platform; balance security and performance.
- Storage I/O: Batch operations where possible; minimize repeated reads/writes.

## Troubleshooting Guide
Common issues and resolutions:
- Validation failures:
  - Invalid format: Ensure key starts with expected prefix and has correct length.
  - Unauthorized: Verify key validity and permissions.
  - API not enabled: Enable Vertex AI API in the project.
  - Network errors: Check connectivity and timeouts.
- Storage errors:
  - Handle StorageError gracefully; log and retry if transient.
- Cloud backup errors:
  - Wrong passphrase: Prompt user to re-enter.
  - Backup not found: Offer restore from another source or recreate.
  - Network errors: Retry with exponential backoff.
- Update failures:
  - New key validation fails: Do not replace; keep existing key.
  - Backup re-encryption fails: Disable backup locally and log warning.
- Presence checks:
  - hasStoredKey/isCloudBackupEnabled return false on storage errors to avoid throwing.

**Section sources**
- [byok_error.dart](file://lib/core/byok/models/byok_error.dart#L7-L94)
- [validation_result.dart](file://lib/core/byok/models/validation_result.dart#L163-L187)
- [byok_manager_test.dart](file://test/byok_manager_test.dart#L1097-L1230)

## Conclusion
The BYOK Manager provides a robust, secure, and extensible foundation for API key lifecycle management. Its Result<T> error handling, metadata-preserving updates, optional cloud backup, and passphrase rotation capabilities ensure reliability and user control. The modular design enables easy testing, platform-specific optimizations, and future enhancements.

## Appendices

### Public Methods Reference
- storeAPIKey(apiKey, projectId): Validates and stores the API key; returns Success or Failure.
- getAPIKey(): Retrieves stored API key configuration; returns Success(APIKeyConfig) or NotFoundError.
- deleteAPIKey(deleteCloudBackup): Deletes local key and optionally cloud backup; returns Success or Failure.
- updateAPIKey(newApiKey, projectId, passphrase?): Validates and replaces the key; preserves metadata; optionally re-encrypts backup.
- enableCloudBackup(passphrase): Encrypts and uploads backup; marks cloud backup enabled.
- disableCloudBackup(deleteBackup): Disables cloud backup and optionally deletes remote backup.
- restoreFromCloudBackup(passphrase): Downloads and decrypts backup; stores locally.
- hasStoredKey(): Checks local key presence.
- isCloudBackupEnabled(): Checks cloud backup flag.
- rotateBackupPassphrase(oldPassphrase, newPassphrase): Re-encrypts backup with new passphrase.

**Section sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L84-L147)

### Practical Usage Patterns
- Store and retrieve:
  - Use storeAPIKey followed by getAPIKey to manage keys.
- Update with backup:
  - Call updateAPIKey with passphrase to re-encrypt backup if enabled.
- Cloud backup lifecycle:
  - Enable via enableCloudBackup; disable via disableCloudBackup; restore via restoreFromCloudBackup.
- Error handling:
  - Always check isSuccess/isFailure and handle specific error types appropriately.

**Section sources**
- [byok_manager_test.dart](file://test/byok_manager_test.dart#L267-L502)
- [byok_manager_test.dart](file://test/byok_manager_test.dart#L508-L700)
- [byok_manager_test.dart](file://test/byok_manager_test.dart#L772-L1091)
- [byok_manager_test.dart](file://test/byok_manager_test.dart#L1236-L1385)