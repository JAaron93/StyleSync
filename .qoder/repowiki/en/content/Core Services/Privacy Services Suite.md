# Privacy Services Suite

<cite>
**Referenced Files in This Document**
- [README.md](file://README.md)
- [docs/security/overview.md](file://docs/security/overview.md)
- [docs/core-services/crypto-services.md](file://docs/core-services/crypto-services.md)
- [docs/core-services/secure-storage-service.md](file://docs/core-services/secure-storage-service.md)
- [docs/core-services/byok-manager.md](file://docs/core-services/byok-manager.md)
- [docs/core-services/onboarding-controller.md](file://docs/core-services/onboarding-controller.md)
- [lib/core/crypto/encryption_service.dart](file://lib/core/crypto/encryption_service.dart)
- [lib/core/crypto/key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart)
- [lib/core/crypto/kdf_metadata.dart](file://lib/core/crypto/kdf_metadata.dart)
- [lib/core/storage/secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart)
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart)
- [lib/core/byok/api_key_validator.dart](file://lib/core/byok/api_key_validator.dart)
- [lib/core/byok/cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart)
- [lib/core/byok/models/api_key_config.dart](file://lib/core/byok/models/api_key_config.dart)
- [lib/features/privacy/widgets/biometric_consent_dialog.dart](file://lib/features/privacy/widgets/biometric_consent_dialog.dart)
- [lib/core/privacy/consent_manager.dart](file://lib/core/privacy/consent_manager.dart)
- [lib/core/auth/models/user_profile.dart](file://lib/core/auth/models/user_profile.dart)
- [lib/core/auth/auth_providers.dart](file://lib/core/auth/auth_providers.dart)
- [lib/core/auth/auth_service.dart](file://lib/core/auth/auth_service.dart)
- [docs/design/firebase-contracts.md](file://docs/design/firebase-contracts.md)
- [test/face_detection_consent_properties_test.dart](file://test/face_detection_consent_properties_test.dart)
</cite>

## Update Summary
**Changes Made**
- Added new section on Biometric Consent Management System
- Updated Privacy Framework Architecture to include biometric consent flow
- Enhanced Consent Management documentation with biometric consent tracking
- Added new diagrams showing biometric consent dialog implementation
- Updated authentication service documentation to include biometric consent handling

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Privacy Framework](#privacy-framework)
6. [Biometric Consent Management System](#biometric-consent-management-system)
7. [Detailed Component Analysis](#detailed-component-analysis)
8. [Dependency Analysis](#dependency-analysis)
9. [Performance Considerations](#performance-considerations)
10. [Troubleshooting Guide](#troubleshooting-guide)
11. [Conclusion](#conclusion)

## Introduction
The Privacy Services Suite is a comprehensive Flutter-based system designed to securely manage sensitive data, primarily focusing on Vertex AI API key lifecycle management with robust encryption, secure storage, and optional cloud backup capabilities. The suite implements defense-in-depth security principles with multiple layers of protection for sensitive data including API keys, authentication tokens, and user credentials.

The system emphasizes user privacy through client-side encryption, platform-native secure storage integration, and minimal data collection practices. It provides a complete solution for managing API keys with optional encrypted cloud backup, ensuring that sensitive data remains protected both at rest and in transit.

**Updated** Enhanced with comprehensive biometric consent management system supporting virtual try-on features with proper state management and back navigation handling.

## Project Structure
The Privacy Services Suite follows a modular architecture organized around core privacy services with integrated biometric consent management:

```mermaid
graph TB
subgraph "Core Services Layer"
A[Secure Storage Service]
B[Crypto Services]
C[BYOK Manager]
D[Onboarding Controller]
E[Consent Manager]
end
subgraph "Feature Layer"
F[Cloud Backup Service]
G[API Key Validator]
H[Biometric Consent Dialog]
end
subgraph "Authentication Layer"
I[Auth Service]
J[Auth Providers]
K[User Profile]
end
subgraph "Models & Interfaces"
L[APIKeyConfig]
M[KdfMetadata]
N[ValidationResult]
O[BiometricConsentDialog]
end
A --> C
B --> C
B --> E
C --> E
C --> F
C --> G
C --> H
E --> I
I --> J
J --> K
K --> O
B --> L
B --> N
F --> L
G --> N
H --> O
```

**Diagram sources**
- [lib/core/storage/secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart#L1-L105)
- [lib/core/crypto/key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L1-L119)
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart#L1-L583)
- [lib/core/privacy/consent_manager.dart](file://lib/core/privacy/consent_manager.dart#L1-L77)
- [lib/features/privacy/widgets/biometric_consent_dialog.dart](file://lib/features/privacy/widgets/biometric_consent_dialog.dart#L1-L80)

The project structure demonstrates clear separation of concerns with distinct modules for each privacy service component, enabling maintainability and testability while ensuring security isolation between different functional areas. The addition of biometric consent management enhances the privacy framework with proper user decision tracking.

**Section sources**
- [README.md](file://README.md#L68-L88)

## Core Components
The Privacy Services Suite comprises five primary security-focused components that work together to provide comprehensive privacy protection:

### Secure Storage Service
Provides platform-agnostic secure storage using native platform mechanisms (iOS Keychain, Android Keystore) with automatic backend selection based on device capabilities. The service offers three security tiers: StrongBox/Hardware-backed, Software-backed encryption, and abstracts platform-specific implementations behind a unified interface.

### Cryptographic Services
Implements industry-standard cryptographic primitives including AES-256-GCM authenticated encryption and adaptive key derivation (Argon2id for mobile, PBKDF2 for web/desktop). The system automatically selects optimal algorithms per platform while maintaining cross-platform compatibility.

### BYOK Manager
Orchestrates the complete API key lifecycle including validation, secure storage, and optional cloud backup. Implements sophisticated error handling, idempotency guarantees, and atomic operations for critical state transitions.

### Cloud Backup Service
Manages encrypted cloud backup operations with atomic passphrase rotation, temporary backup handling, and comprehensive error recovery mechanisms. Ensures data integrity and provides rollback capabilities for critical operations.

### Consent Management System
**New** Provides centralized management of user consent for privacy-sensitive operations including face detection and biometric processing. Tracks consent states separately for different privacy features and maintains persistent storage using SharedPreferences.

**Section sources**
- [docs/core-services/secure-storage-service.md](file://docs/core-services/secure-storage-service.md#L1-L339)
- [docs/core-services/crypto-services.md](file://docs/core-services/crypto-services.md#L1-L333)
- [docs/core-services/byok-manager.md](file://docs/core-services/byok-manager.md#L1-L800)
- [docs/core-services/onboarding-controller.md](file://docs/core-services/onboarding-controller.md#L1-L310)
- [lib/core/privacy/consent_manager.dart](file://lib/core/privacy/consent_manager.dart#L1-L77)

## Architecture Overview
The Privacy Services Suite implements a layered security architecture with clear separation between cryptographic operations, storage abstractions, and business logic, now enhanced with biometric consent management:

```mermaid
sequenceDiagram
participant Client as "Client Application"
participant Consent as "Consent Manager"
participant Dialog as "Biometric Consent Dialog"
participant Auth as "Auth Service"
participant Storage as "Secure Storage"
participant Crypto as "Crypto Services"
Client->>Dialog : showBiometricConsentDialog()
Dialog->>Dialog : setState() for decision tracking
Dialog->>Consent : recordBiometricConsent()
Consent->>Storage : persist consent state
Consent->>Auth : updateBiometricConsent(true)
Auth->>Auth : updateUserProfile()
Auth->>Storage : update user document
Auth-->>Client : consent granted
Note over Dialog,Consent : Stateful widget with proper<br/>back navigation handling and decision tracking
```

**Diagram sources**
- [lib/features/privacy/widgets/biometric_consent_dialog.dart](file://lib/features/privacy/widgets/biometric_consent_dialog.dart#L20-L31)
- [lib/core/privacy/consent_manager.dart](file://lib/core/privacy/consent_manager.dart#L54-L67)
- [lib/core/auth/auth_providers.dart](file://lib/core/auth/auth_providers.dart#L166-L183)

The architecture ensures that sensitive data never leaves the device in plaintext, with all encryption and key derivation operations performed client-side using platform-native cryptographic primitives. The biometric consent system adds proper state management and back navigation handling for enhanced user experience.

## Privacy Framework
The Privacy Services Suite implements a comprehensive privacy framework with separate consent tracking for different privacy-sensitive features:

```mermaid
flowchart TD
A[User Initiates Virtual Try-On] --> B{Has Biometric Consent?}
B --> |Yes| C[Proceed with On-Device Processing]
B --> |No| D[Show Biometric Consent Dialog]
D --> E{User Decision}
E --> |Grant| F[Record Biometric Consent]
E --> |Reject| G[Deny Access]
F --> H[Update User Profile]
H --> I[Enable Virtual Try-On Features]
C --> I
G --> J[Return to Previous Screen]
I --> K[Process Image with Face Detection]
K --> L[Generate Try-On Results]
L --> M[Ephemeral Processing - Immediate Deletion]
M --> N[User Can Save Results if Desired]
```

**Diagram sources**
- [lib/features/privacy/widgets/biometric_consent_dialog.dart](file://lib/features/privacy/widgets/biometric_consent_dialog.dart#L33-L78)
- [lib/core/privacy/consent_manager.dart](file://lib/core/privacy/consent_manager.dart#L54-L67)
- [lib/core/auth/models/user_profile.dart](file://lib/core/auth/models/user_profile.dart#L35-L36)

The privacy framework ensures that biometric processing is opt-in, with explicit user consent required before any facial recognition or biometric data processing occurs. All processing happens on-device with immediate data deletion.

**Section sources**
- [docs/design/firebase-contracts.md](file://docs/design/firebase-contracts.md#L54-L67)

## Biometric Consent Management System
**New Section** The biometric consent management system provides a comprehensive solution for handling user consent for virtual try-on features with proper state management and back navigation handling.

### Biometric Consent Dialog Implementation
The biometric consent dialog is implemented as a StatefulWidget to provide proper state management and handle back navigation gracefully:

```mermaid
classDiagram
class BiometricConsentDialog {
<<StatefulWidget>>
-bool _decisionMade
+VoidCallback onConsentGranted
+VoidCallback onConsentRejected
+createState() _BiometricConsentDialogState
}
class _BiometricConsentDialogState {
<<State>>
-bool _decisionMade
+_handleConsentGranted()
+_handleConsentRejected()
+build(context) Widget
}
class PopScope {
<<Flutter Widget>>
+onPopInvokedWithResult
}
BiometricConsentDialog --> _BiometricConsentDialogState
_BiometricConsentDialogState --> PopScope
```

**Diagram sources**
- [lib/features/privacy/widgets/biometric_consent_dialog.dart](file://lib/features/privacy/widgets/biometric_consent_dialog.dart#L6-L18)
- [lib/features/privacy/widgets/biometric_consent_dialog.dart](file://lib/features/privacy/widgets/biometric_consent_dialog.dart#L20-L31)

The dialog uses a PopScope widget to handle back navigation events and ensures that user decisions are properly tracked even when users navigate back without making a choice.

### Consent State Management
The consent management system tracks biometric consent separately from other privacy consents:

```mermaid
classDiagram
class ConsentManager {
<<abstract>>
+hasFaceDetectionConsent() Future~bool~
+recordFaceDetectionConsent() Future~void~
+revokeFaceDetectionConsent() Future~void~
+hasBiometricConsent() Future~bool~
+recordBiometricConsent() Future~void~
+revokeBiometricConsent() Future~void~
+clearAllConsents() Future~void~
}
class ConsentManagerImpl {
<<implements ConsentManager>>
-SharedPreferences _prefs
-static _faceDetectionConsentKey
-static _biometricConsentKey
+hasBiometricConsent() Future~bool~
+recordBiometricConsent() Future~void~
+revokeBiometricConsent() Future~void~
+clearAllConsents() Future~void~
}
ConsentManager <|.. ConsentManagerImpl
```

**Diagram sources**
- [lib/core/privacy/consent_manager.dart](file://lib/core/privacy/consent_manager.dart#L8-L29)
- [lib/core/privacy/consent_manager.dart](file://lib/core/privacy/consent_manager.dart#L31-L77)

The system maintains separate consent flags for different privacy features, allowing users to grant or revoke consent independently for each feature category.

### Authentication Integration
The biometric consent system integrates seamlessly with the authentication service:

```mermaid
sequenceDiagram
participant User as "User"
participant Dialog as "Biometric Consent Dialog"
participant Consent as "Consent Manager"
participant AuthProv as "Auth Providers"
participant AuthSvc as "Auth Service"
User->>Dialog : Tap "Grant Consent"
Dialog->>Dialog : setState(_decisionMade = true)
Dialog->>Consent : recordBiometricConsent()
Consent->>Consent : persist to SharedPreferences
Consent->>AuthProv : updateBiometricConsent(true)
AuthProv->>AuthSvc : updateBiometricConsent(true)
AuthSvc->>AuthSvc : update user document
AuthSvc-->>AuthProv : success
AuthProv->>AuthProv : update AuthState
AuthProv-->>User : consent recorded
```

**Diagram sources**
- [lib/features/privacy/widgets/biometric_consent_dialog.dart](file://lib/features/privacy/widgets/biometric_consent_dialog.dart#L23-L26)
- [lib/core/privacy/consent_manager.dart](file://lib/core/privacy/consent_manager.dart#L60-L62)
- [lib/core/auth/auth_providers.dart](file://lib/core/auth/auth_providers.dart#L166-L183)

**Section sources**
- [lib/features/privacy/widgets/biometric_consent_dialog.dart](file://lib/features/privacy/widgets/biometric_consent_dialog.dart#L1-L80)
- [lib/core/privacy/consent_manager.dart](file://lib/core/privacy/consent_manager.dart#L1-L77)
- [lib/core/auth/auth_providers.dart](file://lib/core/auth/auth_providers.dart#L166-L183)
- [lib/core/auth/auth_service.dart](file://lib/core/auth/auth_service.dart#L304-L313)

## Detailed Component Analysis

### Secure Storage Service Implementation
The Secure Storage Service provides a unified interface for platform-specific secure storage mechanisms:

```mermaid
classDiagram
class SecureStorageService {
<<abstract>>
+write(key : String, value : String) Future~void~
+read(key : String) Future~String?~
+delete(key : String) Future~void~
+deleteAll() Future~void~
+backend SecureStorageBackend
}
class SecureStorageServiceImpl {
-FlutterSecureStorage _storage
-SecureStorageBackend _backend
-bool _initialized
+write(key : String, value : String) Future~void~
+read(key : String) Future~String?~
+delete(key : String) Future~void~
+deleteAll() Future~void~
+backend SecureStorageBackend
}
class SecureStorageBackend {
<<enumeration>>
strongBox
hardwareBacked
software
}
SecureStorageService <|-- SecureStorageServiceImpl
SecureStorageServiceImpl --> SecureStorageBackend
```

**Diagram sources**
- [lib/core/storage/secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart#L7-L105)

The implementation automatically detects platform capabilities and selects the most secure available backend, falling back to software encryption when hardware security is unavailable. This ensures maximum security across all supported platforms while maintaining consistent behavior.

**Section sources**
- [lib/core/storage/secure_storage_service_impl.dart](file://lib/core/storage/secure_storage_service_impl.dart#L33-L73)

### Cryptographic Services Architecture
The cryptographic subsystem implements multiple layers of security through carefully selected algorithms and parameters:

```mermaid
flowchart TD
A[User Passphrase] --> B{Platform Detection}
B --> |Mobile (Android/iOS/macOS)| C[Argon2id Parameters]
B --> |Web/Desktop| D[PBKDF2 Parameters]
C --> E[3 Iterations<br/>64MB Memory<br/>4 Parallelism]
D --> F[600,000 Iterations<br/>SHA-512 Hash]
E --> G[32-byte Key Derivation]
F --> G
G --> H[AES-256-GCM Encryption]
H --> I[Nonce + Ciphertext + MAC]
J[APIKeyConfig] --> K[JSON Serialization]
K --> L[Encryption]
L --> M[Cloud Storage]
```

**Diagram sources**
- [lib/core/crypto/key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L37-L54)
- [lib/core/crypto/encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L22-L40)

The cryptographic design balances security and performance, with mobile platforms utilizing Argon2id for optimal security and desktop/web platforms using PBKDF2 with high iteration counts for brute force resistance.

**Section sources**
- [docs/core-services/crypto-services.md](file://docs/core-services/crypto-services.md#L89-L144)
- [lib/core/crypto/key_derivation_service.dart](file://lib/core/crypto/key_derivation_service.dart#L56-L81)

### BYOK Manager Business Logic
The BYOK Manager coordinates complex operations involving multiple privacy services with comprehensive error handling and state management:

```mermaid
stateDiagram-v2
[*] --> Uninitialized
Uninitialized --> Validating : storeAPIKey()
Validating --> Storing : Format + Functionality Valid
Validating --> Error : Validation Failed
Storing --> BackupEnabled : Cloud Backup Enabled
Storing --> Ready : Cloud Backup Disabled
BackupEnabled --> Ready : Backup Created
BackupEnabled --> Error : Backup Failed
Ready --> Updating : updateAPIKey()
Ready --> Deleting : deleteAPIKey()
Updating --> Ready : Success
Updating --> Error : Update Failed
Deleting --> [*] : Success
Error --> Ready : Retry
Error --> [*] : Abort
```

**Diagram sources**
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart#L183-L231)
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart#L298-L384)

The manager implements sophisticated idempotency handling, atomic operations for critical state changes, and comprehensive error recovery mechanisms to ensure data consistency across all operations.

**Section sources**
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart#L84-L147)

### Cloud Backup Service Security Model
The cloud backup service implements advanced security measures including atomic operations, temporary backup handling, and comprehensive error recovery:

```mermaid
sequenceDiagram
participant User as "User"
participant CBS as "CloudBackupService"
participant KDF as "KeyDerivationService"
participant ENC as "EncryptionService"
participant FS as "Firebase Storage"
User->>CBS : rotatePassphrase(old, new)
CBS->>CBS : Capture original createdAt
CBS->>FS : Download existing backup
FS-->>CBS : Backup Blob
CBS->>CBS : Decrypt with old passphrase
CBS->>KDF : deriveKey(new, generateMetadata())
KDF-->>CBS : New encryption key
CBS->>ENC : encrypt(config, key)
ENC-->>CBS : Encrypted data
CBS->>FS : Upload to temp path
FS-->>CBS : Success
CBS->>CBS : Verify temp backup
CBS->>FS : Delete original backup
CBS->>FS : Upload to final path
CBS->>FS : Delete temp backup
CBS-->>User : Success
Note over CBS : Two-phase commit pattern<br/>ensures atomicity
```

**Diagram sources**
- [lib/core/byok/cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L414-L555)

The passphrase rotation process implements a sophisticated two-phase commit pattern to ensure atomicity despite Firebase Storage limitations, providing rollback capabilities and recovery mechanisms for critical failure scenarios.

**Section sources**
- [lib/core/byok/cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L413-L555)

### Consent Management System Implementation
**New** The consent management system provides centralized tracking of user consent for privacy-sensitive operations:

```mermaid
classDiagram
class ConsentManager {
<<abstract>>
+hasFaceDetectionConsent() Future~bool~
+recordFaceDetectionConsent() Future~void~
+revokeFaceDetectionConsent() Future~void~
+hasBiometricConsent() Future~bool~
+recordBiometricConsent() Future~void~
+revokeBiometricConsent() Future~void~
+clearAllConsents() Future~void~
}
class ConsentManagerImpl {
<<implements ConsentManager>>
-SharedPreferences _prefs
-static _faceDetectionConsentKey = "face_detection_consent"
-static _biometricConsentKey = "biometric_consent"
+hasBiometricConsent() Future~bool~
+recordBiometricConsent() Future~void~
+revokeBiometricConsent() Future~void~
+clearAllConsents() Future~void~
}
ConsentManager <|.. ConsentManagerImpl
```

**Diagram sources**
- [lib/core/privacy/consent_manager.dart](file://lib/core/privacy/consent_manager.dart#L31-L77)

The implementation uses SharedPreferences for persistent storage and provides separate tracking for face detection consent and biometric consent, allowing granular control over different privacy features.

**Section sources**
- [lib/core/privacy/consent_manager.dart](file://lib/core/privacy/consent_manager.dart#L1-L77)

## Dependency Analysis
The Privacy Services Suite exhibits excellent modularity with clear dependency relationships and low coupling between components, now enhanced with biometric consent management:

```mermaid
graph LR
subgraph "External Dependencies"
A[cryptography package]
B[argon2 package]
C[flutter_secure_storage]
D[firebase_auth]
E[firebase_storage]
F[uuid package]
G[http package]
H[shared_preferences]
I[flutter/material]
end
subgraph "Internal Dependencies"
J[SecureStorageService]
K[EncryptionService]
L[KeyDerivationService]
M[APIKeyValidator]
N[CloudBackupService]
O[BYOKManager]
P[ConsentManager]
Q[BiometricConsentDialog]
R[UserProfile]
S[AuthProviders]
T[AuthService]
end
A --> K
A --> L
B --> L
C --> J
D --> S
E --> N
F --> O
G --> M
H --> P
I --> Q
J --> O
K --> N
L --> N
M --> O
N --> O
P --> R
R --> S
S --> T
Q --> P
```

**Diagram sources**
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart#L1-L15)
- [lib/core/byok/cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L1-L15)
- [lib/features/privacy/widgets/biometric_consent_dialog.dart](file://lib/features/privacy/widgets/biometric_consent_dialog.dart#L1)
- [lib/core/privacy/consent_manager.dart](file://lib/core/privacy/consent_manager.dart#L1)

The dependency graph reveals a clean architecture where cryptographic services are foundational dependencies for higher-level services, while external dependencies are minimized to essential packages only. The addition of biometric consent management introduces new dependencies on shared_preferences and Flutter Material components.

**Section sources**
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart#L1-L15)
- [lib/core/byok/cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L1-L15)
- [lib/features/privacy/widgets/biometric_consent_dialog.dart](file://lib/features/privacy/widgets/biometric_consent_dialog.dart#L1)
- [lib/core/privacy/consent_manager.dart](file://lib/core/privacy/consent_manager.dart#L1)

## Performance Considerations
The Privacy Services Suite implements several performance optimization strategies:

### Cryptographic Performance
- **Compute Isolation**: Heavy cryptographic operations run in isolates to prevent UI blocking
- **Platform Optimization**: Hardware acceleration for AES-GCM and native Argon2 implementations
- **Parameter Tuning**: Optimized KDF parameters balancing security and user experience

### Storage Performance
- **Lazy Initialization**: Secure storage initialized only on first use
- **Async Operations**: All storage operations are asynchronous to prevent blocking
- **Backend Selection**: Automatic selection of fastest available backend

### Network Performance
- **Connection Pooling**: HTTP client managed by validator for efficient network operations
- **Timeout Management**: Configurable timeouts for network operations
- **Error Caching**: Reduced retry attempts for persistent failures

### Consent Management Performance
**New** The consent management system optimizes performance through:
- **Local Storage**: SharedPreferences for fast local consent state retrieval
- **State Caching**: In-memory caching of consent states to reduce disk I/O
- **Batch Operations**: Combined updates to minimize Firestore writes

## Troubleshooting Guide
Common issues and their resolution strategies:

### Secure Storage Issues
- **Device Locked**: iOS device lock or Android keystore availability issues
- **Storage Full**: Insufficient storage space for secure storage operations
- **Permissions Denied**: Platform permission restrictions for secure storage access

### Cryptographic Errors
- **Wrong Passphrase**: Authentication exceptions during decryption
- **Corrupted Data**: MAC verification failures indicating data tampering
- **Algorithm Mismatch**: Version compatibility issues with stored metadata

### Cloud Backup Problems
- **Network Connectivity**: Temporary network failures during backup operations
- **Firebase Quotas**: Rate limiting or quota exceeded errors
- **Atomic Operation Failures**: Partial state during critical operations

### Consent Management Issues
**New** Common consent management issues:
- **Consent State Not Persisting**: SharedPreferences initialization failures
- **Back Navigation Issues**: Dialog state not properly tracked during back navigation
- **Concurrent Consent Updates**: Race conditions in consent state updates
- **Authentication State Sync**: User profile not updating after consent changes

**Section sources**
- [docs/core-services/secure-storage-service.md](file://docs/core-services/secure-storage-service.md#L220-L239)
- [lib/core/byok/cloud_backup_service.dart](file://lib/core/byok/cloud_backup_service.dart#L139-L164)
- [lib/features/privacy/widgets/biometric_consent_dialog.dart](file://lib/features/privacy/widgets/biometric_consent_dialog.dart#L35-L40)

## Conclusion
The Privacy Services Suite represents a comprehensive and well-architected solution for managing sensitive data with robust security guarantees. The implementation demonstrates excellent separation of concerns, with clear abstraction layers that enable maintainability and extensibility while providing strong privacy protections.

**Updated** The recent enhancement of the biometric consent management system significantly strengthens the privacy framework by adding proper state management, back navigation handling, and user decision tracking for virtual try-on features. The system now provides comprehensive consent tracking with separate management for different privacy features, ensuring that users have granular control over their data processing preferences.

Key strengths include the layered security architecture, platform-aware cryptographic implementations, comprehensive error handling, atomic operation guarantees for critical state transitions, and the newly enhanced biometric consent management system. The system successfully balances security, performance, and usability across multiple platforms and deployment scenarios.

The modular design facilitates future enhancements, including potential biometric authentication integration, hardware security module support, expanded cloud storage providers, and additional privacy consent categories. The comprehensive documentation and testing approach ensures long-term maintainability and reliability of the privacy services suite.

The addition of the biometric consent dialog with proper StatefulWidget implementation ensures that user decisions are properly tracked and handled, even during back navigation events. This enhancement improves the overall user experience while maintaining strict privacy controls and data protection standards.