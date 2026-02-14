# Development Guidelines

<cite>
**Referenced Files in This Document**
- [analysis_options.yaml](file://analysis_options.yaml)
- [pubspec.yaml](file://pubspec.yaml)
- [README.md](file://README.md)
- [AGENTS.md](file://AGENTS.md)
- [android/gradle.properties](file://android/gradle.properties)
- [android/build.gradle.kts](file://android/build.gradle.kts)
- [android/key.properties.example](file://android/key.properties.example)
- [ios/Runner/Info.plist](file://ios/Runner/Info.plist)
- [lib/main.dart](file://lib/main.dart)
- [lib/core/crypto/encryption_service.dart](file://lib/core/crypto/encryption_service.dart)
- [lib/core/storage/secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart)
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart)
- [lib/core/byok/byok_design.md](file://lib/core/byok/byok_design.md)
- [lib/core/privacy/auto_tagger_service.dart](file://lib/core/privacy/auto_tagger_service.dart)
- [lib/core/privacy/background_removal_service.dart](file://lib/core/privacy/background_removal_service.dart)
- [lib/core/privacy/face_detection_service.dart](file://lib/core/privacy/face_detection_service.dart)
- [lib/core/onboarding/onboarding_controller.dart](file://lib/core/onboarding/onboarding_controller.dart)
- [lib/core/onboarding/onboarding_controller_impl.dart](file://lib/core/onboarding/onboarding_controller_impl.dart)
- [test/encryption_service_test.dart](file://test/encryption_service_test.dart)
- [test/secure_storage_service_test.dart](file://test/secure_storage_service_test.dart)
- [test/crypto_properties_test.dart](file://test/crypto_properties_test.dart)
- [docs/core-services/byok-manager.md](file://docs/core-services/byok-manager.md)
- [docs/core-services/crypto-services.md](file://docs/core-services/crypto-services.md)
- [docs/core-services/secure-storage-service.md](file://docs/core-services/secure-storage-service.md)
</cite>

## Update Summary
**Changes Made**
- Added comprehensive documentation for new privacy services (AutoTagger, BackgroundRemoval, FaceDetection)
- Expanded onboarding controller documentation with implementation details
- Updated architecture diagrams to reflect expanded service ecosystem
- Enhanced security review process to cover new privacy-focused services
- Added new testing requirements for machine learning and image processing components
- Updated deployment checklist to include new MLKit and TensorFlow Lite dependencies

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Detailed Component Analysis](#detailed-component-analysis)
6. [Privacy Services](#privacy-services)
7. [Onboarding Controller](#onboarding-controller)
8. [Dependency Analysis](#dependency-analysis)
9. [Performance Considerations](#performance-considerations)
10. [Testing Requirements](#testing-requirements)
11. [Security Review Process](#security-review-process)
12. [Deployment Checklist](#deployment-checklist)
13. [Contribution Workflow](#contribution-workflow)
14. [Best Practices](#best-practices)
15. [Debugging and Troubleshooting](#debugging-and-troubleshooting)
16. [Conclusion](#conclusion)

## Introduction
This document provides comprehensive development guidelines for contributing to and maintaining the StyleSync project. It consolidates code style standards, testing requirements, security review processes, deployment procedures, and operational best practices. The project is a Flutter application with a strong focus on cryptography, secure storage, privacy-preserving machine learning, and robust testing patterns.

## Project Structure
The repository follows a conventional Flutter project layout with platform-specific configurations under android/, ios/, linux/, macos/, and windows/. Core business logic resides under lib/, organized by feature and domain (e.g., core/crypto, core/storage, core/byok, core/privacy, core/onboarding). Tests are colocated under test/.

```mermaid
graph TB
subgraph "App Root"
MAIN["lib/main.dart"]
PUBSPEC["pubspec.yaml"]
ANALYSIS["analysis_options.yaml"]
end
subgraph "Core Services"
SECURE_STORAGE["lib/core/storage/secure_storage_service.dart"]
ENCRYPTION["lib/core/crypto/encryption_service.dart"]
BYOK["lib/core/byok/byok_manager.dart"]
ONBOARDING["lib/core/onboarding/onboarding_controller.dart"]
end
subgraph "Privacy Services"
AUTOTAGGER["lib/core/privacy/auto_tagger_service.dart"]
BACKGROUND_REMOVAL["lib/core/privacy/background_removal_service.dart"]
FACE_DETECTION["lib/core/privacy/face_detection_service.dart"]
end
subgraph "Platform Configurations"
ANDROID_GRADLE["android/build.gradle.kts"]
ANDROID_PROPS["android/gradle.properties"]
IOS_INFO["ios/Runner/Info.plist"]
end
MAIN --> SECURE_STORAGE
MAIN --> ENCRYPTION
MAIN --> BYOK
MAIN --> ONBOARDING
MAIN --> AUTOTAGGER
MAIN --> BACKGROUND_REMOVAL
MAIN --> FACE_DETECTION
PUBSPEC --> SECURE_STORAGE
PUBSPEC --> ENCRYPTION
PUBSPEC --> BYOK
PUBSPEC --> ONBOARDING
PUBSPEC --> AUTOTAGGER
PUBSPEC --> BACKGROUND_REMOVAL
PUBSPEC --> FACE_DETECTION
ANDROID_GRADLE --> ANDROID_PROPS
IOS_INFO --> MAIN
```

**Diagram sources**
- [lib/main.dart](file://lib/main.dart#L1-L123)
- [pubspec.yaml](file://pubspec.yaml#L1-L109)
- [analysis_options.yaml](file://analysis_options.yaml#L1-L29)
- [lib/core/storage/secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L1-L36)
- [lib/core/crypto/encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L1-L75)
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart#L1-L583)
- [lib/core/privacy/auto_tagger_service.dart](file://lib/core/privacy/auto_tagger_service.dart#L1-L222)
- [lib/core/privacy/background_removal_service.dart](file://lib/core/privacy/background_removal_service.dart#L1-L94)
- [lib/core/privacy/face_detection_service.dart](file://lib/core/privacy/face_detection_service.dart#L1-L84)
- [lib/core/onboarding/onboarding_controller.dart](file://lib/core/onboarding/onboarding_controller.dart#L1-L47)
- [android/build.gradle.kts](file://android/build.gradle.kts#L1-L25)
- [android/gradle.properties](file://android/gradle.properties#L1-L10)
- [ios/Runner/Info.plist](file://ios/Runner/Info.plist#L1-L50)

**Section sources**
- [lib/main.dart](file://lib/main.dart#L1-L123)
- [pubspec.yaml](file://pubspec.yaml#L1-L109)
- [analysis_options.yaml](file://analysis_options.yaml#L1-L29)
- [android/build.gradle.kts](file://android/build.gradle.kts#L1-L25)
- [android/gradle.properties](file://android/gradle.properties#L1-L10)
- [ios/Runner/Info.plist](file://ios/Runner/Info.plist#L1-L50)

## Core Components
- Secure Storage Service: Defines the interface for platform-native secure storage with hardware-backed and software-backed backends.
- Encryption Service: Provides AES-256-GCM encryption/decryption with authentication and error handling for MAC verification failures.
- BYOK Manager: Orchestrates API key lifecycle, including validation, secure storage, and optional cloud backup with passphrase rotation and atomicity guarantees.
- Privacy Services: Machine learning-powered services for clothing analysis, background removal, and face detection with strict privacy controls.
- Onboarding Controller: Manages user onboarding state persistence and navigation flow.

**Section sources**
- [lib/core/storage/secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L1-L36)
- [lib/core/crypto/encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L1-L75)
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart#L80-L147)
- [lib/core/privacy/auto_tagger_service.dart](file://lib/core/privacy/auto_tagger_service.dart#L1-L222)
- [lib/core/privacy/background_removal_service.dart](file://lib/core/privacy/background_removal_service.dart#L1-L94)
- [lib/core/privacy/face_detection_service.dart](file://lib/core/privacy/face_detection_service.dart#L1-L84)
- [lib/core/onboarding/onboarding_controller.dart](file://lib/core/onboarding/onboarding_controller.dart#L1-L47)

## Architecture Overview
The system emphasizes layered architecture with clear separation of concerns:
- Presentation: Flutter widgets and state management via Riverpod providers.
- Domain: Core services (secure storage, encryption, BYOK manager, privacy services, onboarding controller).
- Infrastructure: Platform integrations (Android/iOS secure storage, Firebase for cloud backup, MLKit for face detection).

```mermaid
graph TB
UI["UI Layer<br/>Widgets/Providers"] --> DOMAIN["Domain Layer<br/>BYOKManager, Validators, Privacy Services"]
DOMAIN --> INFRA["Infrastructure Layer<br/>SecureStorageService, EncryptionService"]
INFRA --> PLATFORM["Platform Integrations<br/>Android/iOS Secure Storage"]
DOMAIN --> FIREBASE["Firebase Services<br/>CloudBackupService (design)"]
DOMAIN --> MLKIT["MLKit Integration<br/>Face Detection"]
DOMAIN --> TFLITE["TensorFlow Lite<br/>Background Removal"]
```

**Diagram sources**
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart#L150-L583)
- [lib/core/storage/secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L10-L36)
- [lib/core/crypto/encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L14-L75)
- [lib/core/byok/byok_design.md](file://lib/core/byok/byok_design.md#L1-L20)
- [lib/core/privacy/face_detection_service.dart](file://lib/core/privacy/face_detection_service.dart#L29-L46)
- [lib/core/privacy/background_removal_service.dart](file://lib/core/privacy/background_removal_service.dart#L6-L16)

## Detailed Component Analysis

### Secure Storage Service
- Responsibilities: Write/read/delete/clear secure values and expose backend type and biometric requirement.
- Backends: hardwareBacked (TEE/Secure Enclave) and software fallback.
- Implementation: Abstract interface with Riverpod provider wiring for dependency injection.

```mermaid
classDiagram
class SecureStorageService {
<<interface>>
+write(key, value) Future~void~
+read(key) Future~String?~
+delete(key) Future~void~
+deleteAll() Future~void~
+backend SecureStorageBackend
}
class SecureStorageBackend {
<<enumeration>>
+strongBox
+hardwareBacked
+software
}
```

**Diagram sources**
- [lib/core/storage/secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L19-L36)

**Section sources**
- [lib/core/storage/secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L1-L36)

### Encryption Service
- Responsibilities: Encrypt and decrypt data using AES-256-GCM with automatic nonce generation and MAC verification.
- Error Handling: Throws a dedicated AuthenticationException on MAC verification failure.
- Key Requirements: Enforces 32-byte key length.

```mermaid
classDiagram
class EncryptionService {
<<interface>>
+encrypt(data, key) Future~Uint8List~
+decrypt(encryptedData, key) Future~Uint8List~
}
class AESGCMEncryptionService {
+encrypt(data, key) Future~Uint8List~
+decrypt(encryptedData, key) Future~Uint8List~
}
class AuthenticationException {
+toString() String
}
EncryptionService <|.. AESGCMEncryptionService
AESGCMEncryptionService --> AuthenticationException : "throws on auth failure"
```

**Diagram sources**
- [lib/core/crypto/encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L23-L31)

**Section sources**
- [lib/core/crypto/encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L1-L75)

### BYOK Manager
- Responsibilities: Store/retrieve/update/delete API keys; enable/disable cloud backup; rotate backup passphrase with atomicity guarantees.
- Validation: Two-stage validation pipeline (format and functionality).
- Security: Integrates with secure storage and encryption services; cloud backup uses KDF metadata and encrypted blobs.

```mermaid
sequenceDiagram
participant Client as "Caller"
participant BYOK as "BYOKManager.storeAPIKey"
participant Validator as "APIKeyValidator"
participant Storage as "SecureStorageService"
participant Cloud as "CloudBackupService"
Client->>BYOK : storeAPIKey(apiKey, projectId)
BYOK->>Validator : validateFormat(apiKey)
Validator-->>BYOK : ValidationSuccess/Failure
BYOK->>Validator : validateFunctionality(apiKey, projectId)
Validator-->>BYOK : ValidationSuccess/Failure
BYOK->>Storage : write(APIKeyConfig JSON)
Storage-->>BYOK : Success/Failure
BYOK-->>Client : Success/Failure
alt Cloud backup enabled
BYOK->>Cloud : createOrUpdateBackup(config, passphrase)
end
```

**Diagram sources**
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart#L182-L231)
- [lib/core/byok/byok_design.md](file://lib/core/byok/byok_design.md#L500-L543)

**Section sources**
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart#L80-L147)
- [lib/core/byok/byok_design.md](file://lib/core/byok/byok_design.md#L293-L438)

## Privacy Services

### Auto Tagger Service
- Responsibilities: Automatically analyze clothing images to extract categories, colors, and seasonal recommendations.
- Implementation: Uses image processing library for dimension analysis, color extraction, and season suggestion algorithms.
- Privacy: Restricts analysis to clothing attributes only, avoiding biometric data extraction.

```mermaid
classDiagram
class AutoTaggerService {
<<interface>>
+analyzeTags(imageFile) Future~ClothingTags~
}
class ClothingTags {
+category String
+colors String[]
+seasons String[]
+additionalAttributes Map
}
class AutoTaggerServiceImpl {
+_categorizeClothing(image) String
+_extractDominantColors(image) String[]
+_suggestSeasons(colors) String[]
}
AutoTaggerService <|.. AutoTaggerServiceImpl
AutoTaggerServiceImpl --> ClothingTags
```

**Diagram sources**
- [lib/core/privacy/auto_tagger_service.dart](file://lib/core/privacy/auto_tagger_service.dart#L13-L19)
- [lib/core/privacy/auto_tagger_service.dart](file://lib/core/privacy/auto_tagger_service.dart#L21-L51)

**Section sources**
- [lib/core/privacy/auto_tagger_service.dart](file://lib/core/privacy/auto_tagger_service.dart#L1-L222)

### Background Removal Service
- Responsibilities: Remove backgrounds from clothing images using TensorFlow Lite models for privacy and offline capability.
- Implementation: Bundled DeepLabV3+ segmentation model with configurable timeout behavior.
- Privacy: 100% on-device processing with no external API calls.

```mermaid
classDiagram
class BackgroundRemovalService {
<<interface>>
+removeBackground(imageFile, timeout) Future~File~
}
class BackgroundRemovalServiceImpl {
-_inputWidth int
-_inputHeight int
+removeBackground(imageFile, timeout) Future~File~
}
BackgroundRemovalService <|.. BackgroundRemovalServiceImpl
```

**Diagram sources**
- [lib/core/privacy/background_removal_service.dart](file://lib/core/privacy/background_removal_service.dart#L17-L36)

**Section sources**
- [lib/core/privacy/background_removal_service.dart](file://lib/core/privacy/background_removal_service.dart#L1-L94)

### Face Detection Service
- Responsibilities: Detect faces in images using ML Kit for privacy protection.
- Implementation: On-device face detection with boolean result output.
- Privacy: No biometric data extraction or storage, 100% on-device processing.

```mermaid
classDiagram
class FaceDetectionService {
<<interface>>
+detectFace(imageFile) Future~bool~
+dispose() Future~void~
}
class FaceDetectionException {
+message String
+originalError Object
+toString() String
}
class FaceDetectionServiceImpl {
+_faceDetector FaceDetector
+detectFace(imageFile) Future~bool~
+dispose() Future~void~
}
FaceDetectionService <|.. FaceDetectionServiceImpl
FaceDetectionServiceImpl --> FaceDetectionException
```

**Diagram sources**
- [lib/core/privacy/face_detection_service.dart](file://lib/core/privacy/face_detection_service.dart#L34-L46)
- [lib/core/privacy/face_detection_service.dart](file://lib/core/privacy/face_detection_service.dart#L5-L27)

**Section sources**
- [lib/core/privacy/face_detection_service.dart](file://lib/core/privacy/face_detection_service.dart#L1-L84)

## Onboarding Controller

### Implementation Details
- Responsibilities: Manage user onboarding state persistence across app sessions.
- Implementation: Uses SharedPreferences with thread-safe initialization and operations.
- Persistence: Stores boolean flag for onboarding completion state.

```mermaid
classDiagram
class OnboardingController {
<<interface>>
+isOnboardingComplete() Future~bool~
+markOnboardingComplete() Future~void~
+resetOnboarding() Future~void~
}
class OnboardingControllerImpl {
-_sharedPreferences SharedPreferences
-_initCompleter Completer
+_getPrefs() Future~SharedPreferences~
+isOnboardingComplete() Future~bool~
+markOnboardingComplete() Future~void~
+resetOnboarding() Future~void~
}
OnboardingController <|.. OnboardingControllerImpl
```

**Diagram sources**
- [lib/core/onboarding/onboarding_controller.dart](file://lib/core/onboarding/onboarding_controller.dart#L17-L46)
- [lib/core/onboarding/onboarding_controller_impl.dart](file://lib/core/onboarding/onboarding_controller_impl.dart#L16-L78)

**Section sources**
- [lib/core/onboarding/onboarding_controller.dart](file://lib/core/onboarding/onboarding_controller.dart#L1-L47)
- [lib/core/onboarding/onboarding_controller_impl.dart](file://lib/core/onboarding/onboarding_controller_impl.dart#L1-L79)

## Dependency Analysis
- Flutter SDK and Dart SDK constraints are defined in pubspec.yaml.
- Core dependencies include cryptography, argon2, firebase_* packages, flutter_secure_storage, riverpod, http, image processing libraries, and MLKit.
- Dev dependencies include flutter_lints, glados, mockito, build_runner, and platform.

```mermaid
graph TB
APP["stylesync (app)"]
CRYPTO["cryptography"]
ARGON2["argon2"]
FIREBASE_CORE["firebase_core"]
FIREBASE_AUTH["firebase_auth"]
FIREBASE_STORAGE["firebase_storage"]
CLOUD_FIRESTORE["cloud_firestore"]
SECURE_STORAGE["flutter_secure_storage"]
RIVERPOD["riverpod / flutter_riverpod"]
HTTP["http"]
LOGGING["logging"]
UUID["uuid"]
PREFS["shared_preferences"]
URL_LAUNCHER["url_launcher"]
IMAGE["image"]
MLKIT_FACE["google_mlkit_face_detection"]
TFLITE["tflite_flutter"]
PATH["path"]
APP --> CRYPTO
APP --> ARGON2
APP --> FIREBASE_CORE
APP --> FIREBASE_AUTH
APP --> FIREBASE_STORAGE
APP --> CLOUD_FIRESTORE
APP --> SECURE_STORAGE
APP --> RIVERPOD
APP --> HTTP
APP --> LOGGING
APP --> UUID
APP --> PREFS
APP --> URL_LAUNCHER
APP --> IMAGE
APP --> MLKIT_FACE
APP --> TFLITE
APP --> PATH
```

**Diagram sources**
- [pubspec.yaml](file://pubspec.yaml#L30-L52)

**Section sources**
- [pubspec.yaml](file://pubspec.yaml#L1-L109)

## Performance Considerations
- Android Gradle Settings: Parallel builds and caching are enabled with balanced JVM arguments to optimize build performance.
- Cryptographic Operations: Use hardware-backed secure storage when available to offload cryptographic operations and improve performance.
- Network Calls: Apply timeouts and handle network errors gracefully in validators and cloud backup operations.
- Image Processing: Implement efficient sampling strategies and configurable timeouts for ML operations.
- Memory Management: Dispose MLKit detectors and cleanup temporary files after processing.

**Section sources**
- [android/gradle.properties](file://android/gradle.properties#L1-L10)
- [lib/core/byok/byok_design.md](file://lib/core/byok/byok_design.md#L642-L742)
- [lib/core/privacy/auto_tagger_service.dart](file://lib/core/privacy/auto_tagger_service.dart#L115-L136)
- [lib/core/privacy/background_removal_service.dart](file://lib/core/privacy/background_removal_service.dart#L84-L92)

## Testing Requirements
- Unit Tests: Located under test/. Examples include encryption_service_test.dart and secure_storage_service_test.dart.
- Property-Based Tests: Uses glados for randomized, repeatable tests focusing on cryptographic round-trips and KDF consistency.
- Privacy Service Testing: Include MLKit and image processing component testing with timeout scenarios.
- Minimum Coverage Thresholds: Not specified in the repository; maintainers should define and enforce coverage targets aligned with security-critical components.
- Security-Critical Patterns:
  - Validate encryption/decryption round-trips.
  - Verify MAC verification failures for wrong keys and tampered ciphertext.
  - Ensure KDF determinism for identical inputs.
  - Mock platform dependencies (e.g., flutter_secure_storage) for isolated unit tests.
  - Test MLKit error handling and timeout scenarios.
  - Validate image processing edge cases and error recovery.

```mermaid
flowchart TD
Start(["Test Execution"]) --> Unit["Unit Tests<br/>flutter_test"]
Start --> Properties["Property-Based Tests<br/>glados"]
Start --> Privacy["Privacy Service Tests<br/>MLKit, Image Processing"]
Unit --> Mocks["Mock Platform Dependencies<br/>mockito"]
Properties --> CryptoProps["Cryptographic Properties<br/>round-trips, KDF consistency"]
Privacy --> MLProps["ML Properties<br/>timeout handling, error recovery"]
Unit --> Security["Security Assertions<br/>authentication exceptions, key length checks"]
Privacy --> PrivacyAssert["Privacy Assertions<br/>no biometric data extraction"]
Security --> Coverage["Coverage Evaluation<br/>targeted for crypto/secure-storage"]
PrivacyAssert --> Coverage
Coverage --> Report["Report & Gate PRs"]
```

**Diagram sources**
- [test/encryption_service_test.dart](file://test/encryption_service_test.dart#L1-L63)
- [test/secure_storage_service_test.dart](file://test/secure_storage_service_test.dart#L1-L147)
- [test/crypto_properties_test.dart](file://test/crypto_properties_test.dart#L1-L97)
- [lib/core/privacy/face_detection_service.dart](file://lib/core/privacy/face_detection_service.dart#L67-L76)
- [lib/core/privacy/background_removal_service.dart](file://lib/core/privacy/background_removal_service.dart#L84-L92)

**Section sources**
- [test/encryption_service_test.dart](file://test/encryption_service_test.dart#L1-L63)
- [test/secure_storage_service_test.dart](file://test/secure_storage_service_test.dart#L1-L147)
- [test/crypto_properties_test.dart](file://test/crypto_properties_test.dart#L1-L97)

## Security Review Process
- Scope: Changes affecting encryption, secure storage, authentication flows, or privacy services require security review.
- Cryptography:
  - AES-256-GCM with 32-byte keys and MAC verification.
  - KDF metadata and deterministic key derivation for backups.
- Secure Storage:
  - Prefer hardware-backed storage when available.
  - Validate backend selection and biometric requirements.
- Authentication:
  - Validate API key format and functionality against Vertex AI endpoints.
  - Ensure proper error propagation and logging without leaking secrets.
- Cloud Backup:
  - Atomic passphrase rotation with upload-before-metadata-commit ordering.
  - Detect and recover from orphaned temp files and metadata inconsistencies.
- Privacy Services:
  - Validate MLKit integration doesn't leak biometric data.
  - Ensure on-device processing for all privacy-sensitive operations.
  - Test error handling and timeout scenarios for ML operations.

```mermaid
flowchart TD
A["Proposed Change"] --> B{"Impacts Security?"}
B --> |No| C["Peer Review Only"]
B --> |Yes| D["Security Review"]
D --> E["Cryptography Review"]
D --> F["Secure Storage Review"]
D --> G["Authentication Review"]
D --> H["Privacy Review"]
E --> I["Acceptance Criteria Met?"]
F --> I
G --> I
H --> I
I --> |No| J["Address Findings"]
I --> |Yes| K["Merge"]
```

**Diagram sources**
- [lib/core/crypto/encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L14-L75)
- [lib/core/storage/secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L1-L36)
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart#L297-L437)
- [lib/core/byok/byok_design.md](file://lib/core/byok/byok_design.md#L380-L432)
- [lib/core/privacy/face_detection_service.dart](file://lib/core/privacy/face_detection_service.dart#L34-L46)

**Section sources**
- [lib/core/crypto/encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L1-L75)
- [lib/core/storage/secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L1-L36)
- [lib/core/byok/byok_manager.dart](file://lib/core/byok/byok_manager.dart#L297-L437)
- [lib/core/byok/byok_design.md](file://lib/core/byok/byok_design.md#L380-L432)
- [lib/core/privacy/face_detection_service.dart](file://lib/core/privacy/face_detection_service.dart#L34-L46)

## Deployment Checklist
- Android
  - Configure keystore properties using android/key.properties.example.
  - Ensure Gradle JVM args, parallel builds, and caching are active.
  - Verify build directory alignment and clean tasks.
  - Include MLKit and TensorFlow Lite dependencies in build configuration.
- iOS
  - Confirm bundle identifiers and build name/version mapping in Info.plist.
  - Ensure entitlements and signing profiles are set up for release.
  - Configure MLKit frameworks and on-device model dependencies.
- Cross-Platform
  - Validate Flutter SDK and Dart SDK constraints.
  - Run flutter pub get and flutter analyze.
  - Execute tests and property-based tests.
  - Include privacy service testing with timeout scenarios.
  - Prepare release notes and version bump per pubspec.yaml.

```mermaid
flowchart TD
Prep["Pre-Release Tasks"] --> Android["Android Build & Signing"]
Prep --> iOS["iOS Build & Signing"]
Android --> Gradle["Gradle Properties & Build Dir"]
iOS --> Info["Info.plist Versioning"]
Prep --> Cross["Pub Get & Analyze"]
Cross --> Tests["Run Unit & Property-Based Tests"]
Cross --> PrivacyTests["Run Privacy Service Tests"]
PrivacyTests --> Security["Security & Privacy Review"]
Tests --> Security
Security --> SignOff["Security & Code Review Sign-Off"]
SignOff --> Release["Publish/Release"]
```

**Diagram sources**
- [android/key.properties.example](file://android/key.properties.example#L1-L5)
- [android/gradle.properties](file://android/gradle.properties#L1-L10)
- [android/build.gradle.kts](file://android/build.gradle.kts#L1-L25)
- [ios/Runner/Info.plist](file://ios/Runner/Info.plist#L1-L50)
- [pubspec.yaml](file://pubspec.yaml#L1-L109)

**Section sources**
- [android/key.properties.example](file://android/key.properties.example#L1-L5)
- [android/gradle.properties](file://android/gradle.properties#L1-L10)
- [android/build.gradle.kts](file://android/build.gradle.kts#L1-L25)
- [ios/Runner/Info.plist](file://ios/Runner/Info.plist#L1-L50)
- [pubspec.yaml](file://pubspec.yaml#L1-L109)

## Contribution Workflow
- Fork and branch from main.
- Install dependencies: flutter pub get.
- Format and lint: dart format . and flutter analyze.
- Run tests: flutter test.
- Include privacy service testing for ML-related changes.
- Commit messages: concise, imperative, explain rationale.
- Open Pull Request: link related issues, summarize changes, tag reviewers.
- Review: address feedback promptly; keep PRs focused and minimal.

**Section sources**
- [AGENTS.md](file://AGENTS.md#L14-L26)
- [AGENTS.md](file://AGENTS.md#L54-L57)

## Best Practices
- Code Style Standards
  - Follow Flutter Lints as configured in analysis_options.yaml.
  - Prefer readability over cleverness; keep imports tidy and remove unused ones.
- Cross-Platform Compatibility
  - Use Riverpod providers for consistent DI across platforms.
  - Abstract platform-specific services behind interfaces (e.g., SecureStorageService).
- Security Considerations
  - Validate keys and inputs rigorously; avoid logging sensitive data.
  - Use hardware-backed secure storage when available.
  - Ensure MAC verification and authentication exceptions are handled.
  - Implement privacy-by-design for ML services (no biometric data extraction).
- Performance Optimization
  - Enable Gradle parallel builds and caching.
  - Minimize unnecessary network calls; apply timeouts and retries judiciously.
  - Optimize image processing with efficient sampling strategies.
  - Dispose MLKit detectors and cleanup temporary files.
- Privacy Compliance
  - Ensure all ML operations are 100% on-device.
  - Implement proper error handling for MLKit failures.
  - Test timeout scenarios and graceful degradation.

**Section sources**
- [analysis_options.yaml](file://analysis_options.yaml#L8-L29)
- [AGENTS.md](file://AGENTS.md#L43-L53)
- [lib/core/storage/secure_storage_service.dart](file://lib/core/storage/secure_storage_service.dart#L1-L36)
- [android/gradle.properties](file://android/gradle.properties#L1-L10)
- [lib/core/privacy/face_detection_service.dart](file://lib/core/privacy/face_detection_service.dart#L34-L46)
- [lib/core/privacy/background_removal_service.dart](file://lib/core/privacy/background_removal_service.dart#L16-L36)

## Debugging and Troubleshooting
- Common Issues
  - Wrong key or corrupted ciphertext leads to AuthenticationException during decryption.
  - Missing or invalid keystore properties cause Android signing failures.
  - Incorrect Info.plist versioning or bundle identifiers on iOS lead to build/signing issues.
  - MLKit initialization failures or model loading errors.
  - Image processing failures with timeout exceptions.
- Procedures
  - Verify encryption round-trips and MAC verification in unit tests.
  - Check secure storage backend and biometric requirements.
  - Confirm Gradle JVM args and parallel caching settings.
  - Review MLKit detector lifecycle and proper disposal.
  - Test privacy service timeout scenarios and error recovery.
  - Validate image file existence and decoding before processing.

**Section sources**
- [test/encryption_service_test.dart](file://test/encryption_service_test.dart#L34-L60)
- [lib/core/crypto/encryption_service.dart](file://lib/core/crypto/encryption_service.dart#L68-L72)
- [android/key.properties.example](file://android/key.properties.example#L1-L5)
- [ios/Runner/Info.plist](file://ios/Runner/Info.plist#L19-L24)
- [lib/core/privacy/face_detection_service.dart](file://lib/core/privacy/face_detection_service.dart#L56-L76)
- [lib/core/privacy/background_removal_service.dart](file://lib/core/privacy/background_removal_service.dart#L47-L92)

## Conclusion
These guidelines consolidate StyleSync's development standards, testing expectations, security practices, and deployment procedures. The expanded architecture now includes comprehensive privacy services with machine learning capabilities while maintaining strict security and privacy controls. Contributors should align changes with the established patterns, ensure rigorous testing (especially for security-critical and privacy services), and follow the documented workflows for code review and releases.