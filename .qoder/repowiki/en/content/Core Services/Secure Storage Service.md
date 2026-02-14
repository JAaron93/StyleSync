# Secure Storage Service

<cite>
**Referenced Files in This Document**
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart)
- [secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart)
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart)
- [byok_storage_keys.dart](file://lib/core/byok/byok_storage_keys.dart)
- [secure_storage_service_test.dart](file://test/secure_storage_service_test.dart)
- [pubspec.yaml](file://pubspec.yaml)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart)
- [api_key_validator.dart](file://lib/core/byok/api_key_validator.dart)
- [byok_design.md](file://lib/core/byok/byok_design.md)
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
This document describes the Secure Storage Service abstraction layer that provides platform-native secure storage across Android, iOS, and web environments. It defines a unified interface for reading, writing, deleting, and checking the existence of sensitive data, with automatic selection of hardware-backed or software-backed storage depending on platform capabilities. The service integrates with the Bring Your Own Key (BYOK) Manager to persist API key configurations securely, and it supports optional cloud backup through encrypted storage.

## Project Structure
The Secure Storage Service resides in the core storage module and is consumed by the BYOK Manager and related services. The key files are:
- Secure storage interface and backend enumeration
- Platform-aware implementation backed by Flutter Secure Storage
- BYOK Manager integration for API key lifecycle management
- Tests validating the implementation behavior

```mermaid
graph TB
subgraph "Core Storage"
SSI["SecureStorageServiceImpl<br/>secure_storage_service_impl.dart"]
SSI_API["SecureStorageService<br/>secure_storage_service.dart"]
end
subgraph "BYOK Integration"
BYOK["BYOKManagerImpl<br/>byok_manager.dart"]
Keys["BYOKStorageKeys<br/>byok_storage_keys.dart"]
end
subgraph "Crypto Services"
ENC["EncryptionService<br/>encryption_service.dart"]
KDF["KeyDerivationService<br/>key_derivation_service.dart"]
end
subgraph "Cloud Backup"
CBS["CloudBackupService<br/>cloud_backup_service.dart"]
end
SSI_API --> SSI
BYOK --> SSI_API
BYOK --> ENC
BYOK --> KDF
BYOK --> CBS
Keys --> BYOK
```

**Diagram sources**
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L10-L29)
- [secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart#L7-L104)
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L153-L582)
- [byok_storage_keys.dart](file://lib/core/byok/byok_storage_keys.dart#L5-L14)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L14-L74)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L9-L117)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L21-L91)

**Section sources**
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L1-L30)
- [secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart#L1-L105)
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L1-L583)
- [byok_storage_keys.dart](file://lib/core/byok/byok_storage_keys.dart#L1-L15)

## Core Components
- SecureStorageBackend: Enumerates hardware-backed (TEE/Secure Enclave) and software-backed storage options.
- SecureStorageService: Abstract interface defining write, read, delete, deleteAll, backend accessor, and biometric requirement indicator.
- SecureStorageServiceImpl: Platform-aware implementation that selects hardware-backed storage on Android and iOS, and falls back to software-backed storage on other platforms. It initializes FlutterSecureStorage with platform-appropriate options and exposes the same interface.

Key behaviors:
- Backend selection is automatic based on platform detection.
- Initialization uses a Completer to ensure asynchronous initialization completes before operations.
- On Android, AES-GCM options are configured to leverage hardware protection when available.
- On iOS, Keychain accessibility is configured for device-locked access.
- On non-mobile/web platforms, software-backed storage is used.

**Section sources**
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L1-L30)
- [secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart#L7-L104)

## Architecture Overview
The Secure Storage Service sits between the BYOK Manager and the Flutter Secure Storage plugin. The BYOK Manager validates API keys, constructs configurations, and persists them using the Secure Storage Service. Cloud backup is handled separately by the CloudBackupService, which uses the crypto services to encrypt and upload backups to Firebase Storage.

```mermaid
sequenceDiagram
participant UI as "UI Layer"
participant BYOK as "BYOKManagerImpl"
participant SSS as "SecureStorageService"
participant FSS as "FlutterSecureStorage"
participant CBS as "CloudBackupService"
UI->>BYOK : storeAPIKey(apiKey, projectId)
BYOK->>BYOK : validateFormat()
BYOK->>BYOK : validateFunctionality()
BYOK->>SSS : write(BYOKStorageKeys.apiKeyConfig, configJson)
SSS->>FSS : write(key, value)
FSS-->>SSS : success
SSS-->>BYOK : success
BYOK->>CBS : createOrUpdateBackup(config, passphrase)
BYOK-->>UI : Success
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L182-L231)
- [secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart#L75-L97)
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L167-L249)

## Detailed Component Analysis

### SecureStorageService Interface
Defines the contract for secure storage operations:
- write(key, value): Asynchronous write operation.
- read(key): Asynchronous read operation returning nullable string.
- delete(key): Asynchronous delete operation.
- deleteAll(): Asynchronous clear-all operation.
- backend: Current backend in use (hardwareBacked or software).
- requiresBiometric: Indicates whether access requires biometric or device passcode (currently false pending future implementation).

Security implications:
- The interface abstracts platform differences, enabling transparent use of hardware-backed storage on capable devices.

**Section sources**
- [secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L10-L29)

### SecureStorageServiceImpl Implementation
Platform-specific initialization and behavior:
- Android: Uses AndroidOptions with AES-GCM and reset-on-error enabled. Defaults to hardwareBacked backend.
- iOS: Uses IOSOptions with accessibility targeting unlocked device state. Defaults to hardwareBacked backend.
- Other platforms: Uses default FlutterSecureStorage configuration. Defaults to software backend.
- Initialization safety: Uses a Completer to ensure initialization completes before any operation executes.
- Fallback: On initialization failure, falls back to software-backed storage and logs the error.

Hardware security module integration:
- Android: AES-GCM with hardware protection when available via Flutter Secure Storage v10.0.0+ defaults.
- iOS: Keychain-backed storage leveraging Secure Enclave when available.

Error handling:
- Initialization catches exceptions and switches to software-backed storage.
- Operations await initialization completion via Completer.

```mermaid
flowchart TD
Start(["Initialize SecureStorageServiceImpl"]) --> CheckInjected{"Injected storage?"}
CheckInjected --> |Yes| UseInjected["Use injected storage and backend"]
CheckInjected --> |No| DetectPlatform["Detect platform"]
DetectPlatform --> Android{"Android?"}
Android --> |Yes| InitAndroid["Initialize with AndroidOptions (AES-GCM)"]
Android --> |No| IOS{"iOS?"}
IOS --> |Yes| InitIOS["Initialize with IOSOptions (Keychain)"]
IOS --> |No| InitSoftware["Initialize with default FlutterSecureStorage"]
InitAndroid --> SetBackendHW["Set backend = hardwareBacked"]
InitIOS --> SetBackendHW
InitSoftware --> SetBackendSW["Set backend = software"]
SetBackendHW --> Complete["Complete initialization"]
SetBackendSW --> Complete
UseInjected --> Complete
Complete --> End(["Ready"])
```

**Diagram sources**
- [secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart#L33-L73)

**Section sources**
- [secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart#L7-L104)

### BYOK Manager Integration
The BYOK Manager uses SecureStorageService to persist API key configurations:
- Storage keys: apiKeyConfig, cloudBackupEnabled, backupPassphraseHash.
- Store: Validates key format and functionality, serializes configuration, writes to secure storage.
- Retrieve: Reads from secure storage, deserializes configuration.
- Delete: Removes configuration and optionally cloud backup keys.
- Update: Validates new key, preserves metadata, writes updated configuration, optionally re-encrypts cloud backup.
- Enable/Disable cloud backup: Persists flags and manages cloud backup lifecycle.
- Restore: Downloads and decrypts cloud backup, stores locally.
- Has Stored Key / Is Cloud Backup Enabled: Reads flags from secure storage.

```mermaid
sequenceDiagram
participant BYOK as "BYOKManagerImpl"
participant SSS as "SecureStorageService"
participant Keys as "BYOKStorageKeys"
BYOK->>SSS : read(Keys.apiKeyConfig)
alt Found
SSS-->>BYOK : JSON string
BYOK->>BYOK : parse JSON to APIKeyConfig
BYOK-->>Caller : Success(APIKeyConfig)
else Not Found
SSS-->>BYOK : null
BYOK-->>Caller : Failure(NotFoundError)
end
```

**Diagram sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L233-L256)
- [byok_storage_keys.dart](file://lib/core/byok/byok_storage_keys.dart#L5-L14)

**Section sources**
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L153-L582)
- [byok_storage_keys.dart](file://lib/core/byok/byok_storage_keys.dart#L5-L14)

### Cloud Backup Service Integration
While not part of the Secure Storage Service, CloudBackupService complements it by encrypting and uploading API key configurations to Firebase Storage. It uses the crypto services to derive keys and encrypt data, then stores encrypted blobs with KDF metadata.

```mermaid
sequenceDiagram
participant BYOK as "BYOKManagerImpl"
participant CBS as "CloudBackupService"
participant ENC as "EncryptionService"
participant KDF as "KeyDerivationService"
participant FS as "Firebase Storage"
BYOK->>CBS : createOrUpdateBackup(config, passphrase)
CBS->>KDF : generateMetadata()
CBS->>KDF : deriveKey(passphrase, metadata)
CBS->>ENC : encrypt(configJsonBytes, key)
CBS->>FS : upload(blobJson)
FS-->>CBS : success
CBS-->>BYOK : Success
```

**Diagram sources**
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L167-L249)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L22-L74)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L17-L85)

**Section sources**
- [cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L21-L91)
- [encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L14-L74)
- [key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L9-L117)

## Dependency Analysis
External dependencies relevant to Secure Storage:
- flutter_secure_storage: Provides platform-native secure storage abstraction.
- platform: Used to detect platform type for backend selection.
- cryptography and argon2: Used by CloudBackupService for encryption and key derivation.

```mermaid
graph LR
SSI["SecureStorageServiceImpl"] --> FSS["flutter_secure_storage"]
SSI --> P["platform"]
BYOK["BYOKManagerImpl"] --> SSI
BYOK --> ENC["EncryptionService"]
BYOK --> KDF["KeyDerivationService"]
BYOK --> CBS["CloudBackupService"]
```

**Diagram sources**
- [secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart#L1-L5)
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L1-L15)
- [pubspec.yaml](file://pubspec.yaml#L34-L47)

**Section sources**
- [pubspec.yaml](file://pubspec.yaml#L30-L47)
- [secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart#L1-L5)
- [byok_manager.dart](file://lib/core/byok/byok_manager.dart#L1-L15)

## Performance Considerations
- Android hardware-backed storage: AES-GCM with hardware acceleration improves performance for encryption/decryption operations when available.
- iOS Keychain-backed storage: Access is optimized for device-locked scenarios and leverages Secure Enclave when present.
- Software-backed storage: Slower than hardware-backed due to pure software encryption; suitable for non-mobile/web platforms.
- Initialization overhead: The Completer-based initialization ensures operations wait for readiness, preventing race conditions at the cost of a small startup delay.
- Error handling: Fallback to software-backed storage avoids blocking the app on initialization failures.

[No sources needed since this section provides general guidance]

## Troubleshooting Guide
Common issues and resolutions:
- Initialization failures: The implementation logs and falls back to software-backed storage. Check platform detection and Flutter Secure Storage configuration.
- Operation timing: Ensure callers await initialization completion; operations are gated by a Completer to prevent premature access.
- Backend mismatches: Confirm platform detection logic and Flutter Secure Storage options for Android and iOS.
- Test coverage: Unit tests validate that write/read/delete/deleteAll delegate to the underlying storage and return expected results.

**Section sources**
- [secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart#L63-L72)
- [secure_storage_service_test.dart](file://test/secure_storage_service_test.dart#L10-L147)

## Conclusion
The Secure Storage Service provides a robust, platform-aware abstraction for secure data persistence. It automatically selects hardware-backed storage on Android and iOS, with a reliable software-backed fallback for other platforms. Integrated with the BYOK Manager, it enables secure API key lifecycle management, complemented by optional cloud backup through encrypted storage. The design balances security, portability, and maintainability across diverse deployment targets.