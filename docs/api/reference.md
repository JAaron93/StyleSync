# API Reference

## Core Services

### BYOK Manager
Complete API key lifecycle management.

**Documentation**: [BYOK Manager](../core-services/byok-manager.md)

**Key Methods**:
- `storeAPIKey(String apiKey, String projectId)`: Store and validate API key
- `getAPIKey()`: Retrieve stored API key
- `deleteAPIKey()`: Remove API key from storage
- `hasAPIKey()`: Check if API key exists

### Encryption Service
AES-256-GCM encryption operations.

**Documentation**: [Crypto Services](../core-services/crypto-services.md)

**Key Methods**:
- `encrypt(Uint8List plaintext, Uint8List key)`: Encrypt data
- `decrypt(Uint8List encrypted, Uint8List key)`: Decrypt data

### Key Derivation Service
Passphrase-based key derivation.

**Documentation**: [Crypto Services](../core-services/crypto-services.md)

**Key Methods**:
- `deriveKey(String passphrase, KdfMetadata metadata)`: Derive encryption key
- `generateMetadata()`: Create KDF parameters

### Secure Storage Service
Platform-native secure storage.

**Documentation**: [Secure Storage Service](../core-services/secure-storage-service.md)

**Key Methods**:
- `write({required String key, required String value})`: Store data
- `read({required String key})`: Retrieve data
- `delete({required String key})`: Remove specific key
- `deleteAll()`: Clear all data

### Onboarding Controller
Onboarding persistence management.

**Documentation**: [Onboarding Controller](../core-services/onboarding-controller.md)

**Key Methods**:
- `markOnboardingComplete()`: Mark onboarding as done
- `isOnboardingComplete()`: Check completion status
- `resetOnboarding()`: Reset for testing

## Riverpod Providers

### Core Providers
- `byokManagerProvider`: BYOKManager instance
- `encryptionServiceProvider`: EncryptionService instance
- `keyDerivationServiceProvider`: KeyDerivationService instance
- `secureStorageServiceProvider`: SecureStorageService instance
- `onboardingControllerProvider`: OnboardingController instance

### State Providers
- `onboardingStateProvider`: Current onboarding flow state
- `isOnboardingCompleteProvider`: Async completion check

## Models

### APIKeyConfig
```dart
class APIKeyConfig {
  final String apiKey;
  final String projectId;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

### KdfMetadata
```dart
class KdfMetadata {
  final KdfAlgorithm algorithm;
  final Uint8List salt;
  final int iterations;
  final int? memory;       // Argon2 only
  final int? parallelism;  // Argon2 only
}
```

### OnboardingState
```dart
class OnboardingState {
  final OnboardingStep step;
  final bool isLoading;
  final String? error;
}

enum OnboardingStep {
  welcome,
  tutorial,
  apiKeyInput,
  complete,
}
```

## Related Documentation

- [Architecture Overview](../architecture/overview.md) - System design
- [Core Services Documentation](../core-services/byok-manager.md) - Detailed APIs
