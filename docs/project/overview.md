# Project Overview

## Introduction

StyleSync is a Flutter application that leverages Firebase for backend services and Riverpod for state management. The project places a strong emphasis on security (cryptography, secure storage) and testing (property-based testing).

## Core Principles

### Security-First Design
- **End-to-end encryption** for sensitive data
- **Platform-native secure storage** (iOS Keychain, Android Keystore)
- **Memory protection** for API keys and sensitive credentials
- **No backend transmission** of unencrypted sensitive data

### Robust Testing
- **Unit tests** using `flutter_test` and `mockito`
- **Property-based testing** using `glados` for complex state transitions and cryptography
- **High test coverage** with focus on security-critical components

### Clean Architecture
- **Separation of concerns** with clear boundaries between layers
- **Dependency injection** using Riverpod providers
- **Reactive state management** for responsive UI
- **Platform abstraction** for testability and flexibility

## Technology Stack

### Core Frameworks
- **Flutter SDK**: Cross-platform mobile development framework
- **Dart**: Primary programming language

### Backend Services
- **Firebase Core**: Firebase integration
- **Firebase Auth**: User authentication
- **Firebase Storage**: Cloud storage for encrypted backups
- **Cloud Firestore**: (planned) NoSQL database

### State Management
- **Riverpod**: Reactive state management and dependency injection
- **Flutter Riverpod**: Flutter-specific Riverpod integration

### Security & Cryptography
- **Flutter Secure Storage**: Platform-native secure storage
- **Argon2**: Memory-hard key derivation function
- **Cryptography Package**: AES-256-GCM encryption, PBKDF2 fallback

### Testing
- **Flutter Test**: Standard Flutter testing framework
- **Mockito**: Mocking framework for unit tests
- **Glados**: Property-based testing framework

## Key Features

### Bring Your Own Key (BYOK) System
Users can securely manage their personal Vertex AI API keys with:
- Format validation and functional testing
- Secure local storage using platform-native features
- Optional encrypted cloud backup with user-controlled passphrase

### Secure Cloud Backup
- Client-side encryption before upload
- Argon2id/PBKDF2 key derivation from user passphrase
- Atomic passphrase rotation with rollback protection
- Firebase Storage with strict security rules

### Onboarding Flow
- Multi-step guided onboarding experience
- Persistent completion tracking across app restarts
- API key input with real-time validation
- Tutorial pages for user education

### Platform Support
- **Android**: Min SDK 24 (Android 8.0+)
- **iOS**: Min deployment target 14.0
- **Web**: PBKDF2 fallback for key derivation
- **macOS, Linux, Windows**: Desktop platform support

## Project Structure

```
lib/
├── core/                          # Core services and infrastructure
│   ├── byok/                      # BYOK system
│   ├── crypto/                    # Cryptography services
│   ├── onboarding/                # Onboarding controller
│   └── storage/                   # Secure storage service
├── features/                      # Feature implementations
│   └── onboarding/                # Onboarding UI screens
└── main.dart                      # Application entry point

test/                              # Test suites
├── core/                          # Core service tests
├── features/                      # Feature tests
├── *_test.dart                    # Unit tests
└── *_property_test.dart           # Property-based tests
```

## Design Philosophy

### Fail-Safe Defaults
- Errors are handled gracefully with clear failure modes
- Default to most secure options when choices are available
- Rate limiting and timeouts prevent abuse and hanging

### Idempotency
- Operations can be safely retried without side effects
- State transitions are predictable and consistent
- Storage operations are atomic where possible

### Observability
- Structured logging for debugging and monitoring
- Metrics for performance tracking (rotation duration, KDF time, etc.)
- Clear error messages without exposing sensitive details

### Privacy by Design
- API keys never logged, even in debug builds
- Passphrases never stored, only derived keys used
- Cloud backups encrypted client-side before upload
- Firebase security rules prevent unauthorized access

## Development Status

The project is currently in active development with:
- ✅ Core cryptography services implemented
- ✅ Secure storage foundation established
- ✅ BYOK manager with validation pipeline
- ✅ Onboarding flow with persistence
- ✅ Cloud backup service with passphrase rotation
- 🔄 Additional features in planning

## Related Documentation

- [Getting Started](./getting-started.md) - Setup and installation guide
- [Architecture Overview](../architecture/overview.md) - System design details
- [Security Overview](../security/overview.md) - Security implementation
- [Development Guidelines](../guidelines/development-guidelines.md) - Coding standards
