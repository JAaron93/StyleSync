# Secure Storage Service

## Overview

The Secure Storage Service provides a platform-agnostic interface for storing sensitive data using platform-native secure storage mechanisms (iOS Keychain, Android Keystore). It automatically selects the most secure backend available on each platform.

## Purpose

- Store API keys, authentication tokens, and other sensitive data
- Utilize hardware-backed security when available
- Provide consistent interface across all platforms
- Abstract platform-specific implementation details

## Interface

**File**: [`lib/core/storage/secure_storage_service.dart`](../../lib/core/storage/secure_storage_service.dart)

```dart
abstract class SecureStorageService {
  /// Writes a key-value pair to secure storage.
  Future<void> write({required String key, required String value});
  
  /// Reads a value from secure storage.
  /// Returns null if key doesn't exist.
  Future<String?> read({required String key});
  
  /// Deletes a specific key from secure storage.
  Future<void> delete({required String key});
  
  /// Deletes all keys from secure storage.
  Future<void> deleteAll();
  
  /// Gets the security backend being used.
  SecureStorageBackend get backend;
}
```

### Security Backend Enum

```dart
enum SecureStorageBackend {
  strongBox,       // Android StrongBox (hardware security module)
  hardwareBacked,  // Hardware-backed (TEE on Android, Keychain on iOS)
  software,        // Software-backed encryption
}
```

## Implementation

**File**: [`lib/core/storage/secure_storage_service_impl.dart`](../../lib/core/storage/secure_storage_service_impl.dart)

### Platform-Specific Configurations

#### Android
```dart
AndroidOptions _getAndroidOptions() {
  return AndroidOptions(
    encryptedSharedPreferences: true,
    // Use AES-GCM for maximum security
    keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
  );
}
```

**Security Features**:
- **StrongBox**: Hardware security module (if available)
- **TEE (Trusted Execution Environment)**: Hardware-backed keys
- **Android Keystore**: Isolated key storage
- **AES-GCM**: Authenticated encryption for data

**Backend Selection Priority**:
1. StrongBox (Samsung, Google Pixel 3+)
2. Hardware-backed TEE (most modern devices)
3. Software-backed (fallback)

#### iOS
```dart
IOSOptions _getIOSOptions() {
  return IOSOptions(
    accessibility: KeychainAccessibility.unlocked_this_device,
  );
}
```

**Security Features**:
- **Keychain**: iOS secure credential storage
- **Hardware Encryption**: Uses Secure Enclave when available
- **Accessibility Control**: Data only accessible when device unlocked
- **No iCloud Sync**: `unlocked_this_device` prevents cloud backup

**Accessibility Levels**:
- `unlocked_this_device`: Most secure, no iCloud sync
- `unlocked`: Accessible when unlocked, syncs to iCloud
- `first_unlock`: Accessible after first unlock

### Usage Example

```dart
// Get service instance (usually via Riverpod)
final storage = ref.read(secureStorageServiceProvider);

// Write sensitive data
await storage.write(
  key: 'api_key',
  value: 'AIzaSyD...',
);

// Read data
final apiKey = await storage.read(key: 'api_key');

// Delete specific key
await storage.delete(key: 'api_key');

// Clear all data
await storage.deleteAll();

// Check backend
print('Using: ${storage.backend}'); // e.g., hardwareBacked
```

## Integration with BYOK Manager

The BYOK Manager uses Secure Storage to persist API key configurations:

```dart
class BYOKManagerImpl implements BYOKManager {
  final SecureStorageService _secureStorage;
  
  static const String _apiKeyConfigKey = 'api_key_config';
  
  @override
  Future<Result<void>> storeAPIKey(String apiKey, String projectId) async {
    final config = APIKeyConfig(
      apiKey: apiKey,
      projectId: projectId,
      createdAt: DateTime.now(),
    );
    
    await _secureStorage.write(
      key: _apiKeyConfigKey,
      value: jsonEncode(config.toJson()),
    );
    
    return Success(null);
  }
  
  @override
  Future<Result<APIKeyConfig>> getAPIKey() async {
    final json = await _secureStorage.read(key: _apiKeyConfigKey);
    if (json == null) {
      return Failure(BYOKError.notFound);
    }
    
    final config = APIKeyConfig.fromJson(jsonDecode(json));
    return Success(config);
  }
}
```

## Platform Security Details

### Android Keystore

#### Hardware-Backed Storage
- **Location**: Secure hardware (TEE or StrongBox)
- **Protection**: Keys never leave secure hardware
- **Operations**: Encryption/decryption in hardware
- **Attestation**: Can verify hardware backing

#### StrongBox
- **Availability**: Android 9+ with dedicated HSM
- **Hardware**: Separate security chip (e.g., Titan M on Pixel)
- **Protection**: Physical tamper resistance
- **Performance**: Slightly slower but maximum security

#### Software Fallback
- **When Used**: Older devices without hardware support
- **Protection**: Android Keystore with software keys
- **Security**: Still better than unencrypted storage

### iOS Keychain

#### Secure Enclave
- **Availability**: iPhone 5s and later, iPad Air 2 and later
- **Hardware**: Dedicated crypto coprocessor
- **Protection**: Keys never leave Secure Enclave
- **Touch ID/Face ID**: Integrates biometric authentication

#### Accessibility Options

| Level | When Accessible | iCloud Sync | Use Case |
|-------|----------------|-------------|----------|
| `unlocked_this_device` | Device unlocked | No | API keys, tokens (most secure) |
| `unlocked` | Device unlocked | Yes | User preferences |
| `first_unlock` | After first unlock | Yes | Background data |
| `always` | Always | Yes | Not recommended |

**StyleSync Choice**: `unlocked_this_device` for maximum security

## Security Considerations

### Data Protection
- **Encryption at Rest**: All data encrypted by platform
- **Hardware Isolation**: Keys stored in hardware when available
- **Memory Protection**: Data cleared after use
- **No Logging**: Sensitive data never logged

### Key Management
- **Per-App Isolation**: Each app has isolated keychain/keystore
- **OS-Managed**: Platform handles key lifecycle
- **Backup Control**: Can prevent cloud backup of sensitive data

### Best Practices
1. **Use for Sensitive Data Only**: Secure storage has performance overhead
2. **Clear When Not Needed**: Use `deleteAll()` on logout
3. **Check Backend**: Inform users about security level
4. **Handle Failures**: Platform storage can fail (device locked, storage full)

## Error Handling

```dart
try {
  await storage.write(key: 'api_key', value: apiKey);
} catch (e) {
  // Platform storage errors:
  // - Device locked (iOS)
  // - Keystore unavailable (Android)
  // - Storage full
  // - Permissions denied
  handleStorageError(e);
}
```

### Common Errors
- **iOS**: Device locked, keychain access denied
- **Android**: Keystore unavailable, key permanently invalidated
- **All Platforms**: Storage full, permissions issues

## Testing

### Unit Tests
**File**: [`test/secure_storage_service_test.dart`](../../test/secure_storage_service_test.dart)

Tests use mock secure storage for isolation:
- Write/read round-trip
- Key deletion
- Delete all operation
- Null handling for missing keys

### Property-Based Tests
**File**: [`test/secure_storage_property_test.dart`](../../test/secure_storage_property_test.dart)

- **Property**: Backend selection based on platform
- **Property**: Multiple write operations are idempotent
- **Property**: Read returns last written value

### Mock Implementation

```dart
class MockSecureStorage implements SecureStorageService {
  final _storage = <String, String>{};
  
  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }
  
  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }
  
  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }
  
  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }
  
  @override
  SecureStorageBackend get backend => SecureStorageBackend.software;
}
```

## Performance Characteristics

### Read/Write Latency
- **Hardware-Backed**: 10-50ms
- **Software-Backed**: 5-20ms
- **First Access**: May be slower due to keychain/keystore unlock

### Recommendations
- **Minimize Reads**: Cache data when possible
- **Batch Operations**: Not supported, but minimize separate calls
- **Async Operations**: Always await, don't block UI

## Riverpod Integration

```dart
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageServiceImpl();
});

// Usage in other services
final byokManagerProvider = Provider<BYOKManager>((ref) {
  final storage = ref.read(secureStorageServiceProvider);
  final validator = ref.read(apiKeyValidatorProvider);
  return BYOKManagerImpl(
    secureStorage: storage,
    apiKeyValidator: validator,
  );
});
```

## Migration and Upgrades

### Platform Updates
- **Android 9+**: Automatically uses StrongBox if available
- **iOS Updates**: Secure Enclave improvements transparent
- **No Code Changes**: Platform handles upgrades

### Data Migration
When changing storage backend or encryption:
1. Read existing data
2. Delete old storage
3. Write with new configuration
4. Verify migration success

## Related Documentation

- [BYOK Manager](./byok-manager.md) - Primary consumer of secure storage
- [Architecture Overview](../architecture/overview.md) - System integration
- [Security Overview](../security/overview.md) - Security architecture
- [Testing Strategy](../testing/strategy.md) - Testing approach
