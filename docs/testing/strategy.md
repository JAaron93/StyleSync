# Testing Strategy

## Testing Philosophy

StyleSync emphasizes comprehensive testing with a focus on security-critical components. The testing strategy combines traditional unit tests with property-based testing for complex state machines and cryptographic operations.

## Test Types

### Unit Tests
**Location**: `test/*_test.dart`

**Tools**:
- `flutter_test`: Flutter testing framework
- `mockito`: Mocking dependencies

**Coverage**:
- Individual service methods
- Error handling
- Edge cases
- Integration points

**Examples**:
- [`test/encryption_service_test.dart`](../../test/encryption_service_test.dart)
- [`test/secure_storage_service_test.dart`](../../test/secure_storage_service_test.dart)
- [`test/byok_manager_test.dart`](../../test/byok_manager_test.dart)

### Property-Based Tests
**Location**: `test/*_property_test.dart` or `test/*_properties_test.dart`

**Tool**: `glados`

**Coverage**:
- State transitions
- Cryptographic operations
- Validation pipelines
- Idempotency
- Consistency

**Examples**:
- [`test/crypto_properties_test.dart`](../../test/crypto_properties_test.dart) - Encryption round-trip, KDF consistency
- [`test/byok_properties_test.dart`](../../test/byok_properties_test.dart) - API key validation
- [`test/core/onboarding/onboarding_persistence_property_test.dart`](../../test/core/onboarding/onboarding_persistence_property_test.dart) - Onboarding persistence

### Widget Tests
**Location**: `test/features/**/*_test.dart`

**Coverage**:
- UI component rendering
- User interactions
- Navigation
- State updates

**Examples**:
- [`test/features/onboarding/onboarding_screen_test.dart`](../../test/features/onboarding/onboarding_screen_test.dart)
- [`test/features/onboarding/widgets/api_key_input_page_test.dart`](../../test/features/onboarding/widgets/api_key_input_page_test.dart)

## Property-Based Testing with Glados

### When to Use
- Complex state transitions
- Cryptographic operations
- Validation logic
- Operations that should be idempotent
- Consistency requirements

### Example Properties

#### Encryption Round-Trip
```dart
Glados(any.list(any.int)).test(
  'Encrypt then decrypt returns original data',
  (data) async {
    final key = Uint8List(32);
    final plaintext = Uint8List.fromList(data);
    
    final encrypted = await service.encrypt(plaintext, key);
    final decrypted = await service.decrypt(encrypted, key);
    
    expect(decrypted, equals(plaintext));
  },
);
```

#### KDF Consistency
```dart
Glados2(any.nonEmptyLowercaseLetters, any.int).test(
  'KDF produces consistent keys',
  (password, seed) async {
    final metadata = KdfMetadata(...);
    
    final key1 = await kdf.deriveKey(password, metadata);
    final key2 = await kdf.deriveKey(password, metadata);
    
    expect(key1, equals(key2));
  },
);
```

#### Onboarding Persistence
```dart
Glados(any.smallPositiveInt).test(
  'Onboarding completion persists across instances',
  (restartCount) async {
    final controller = await createController();
    await controller.markOnboardingComplete();
    
    for (var i = 0; i < restartCount; i++) {
      final newController = await createController();
      expect(await newController.isOnboardingComplete(), isTrue);
    }
  },
);
```

## Running Tests

### All Tests
```bash
flutter test
```

### Specific Test File
```bash
flutter test test/encryption_service_test.dart
```

### With Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Property Tests Only
```bash
flutter test --name "Property"
```

## Test Organization

```
test/
├── core/
│   ├── onboarding/
│   │   └── onboarding_persistence_property_test.dart
├── features/
│   ├── onboarding/
│   │   ├── onboarding_screen_test.dart
│   │   └── widgets/
│   │       ├── api_key_input_page_test.dart
│   │       ├── tutorial_page_test.dart
│   │       └── welcome_page_test.dart
├── byok_manager_test.dart
├── byok_properties_test.dart
├── crypto_properties_test.dart
├── encryption_service_test.dart
├── key_derivation_service_test.dart
├── secure_storage_property_test.dart
└── secure_storage_service_test.dart
```

## Mocking with Mockito

### Setup
```dart
@GenerateMocks([HttpClient, SecureStorageService])
void main() {
  // Tests here
}
```

### Generate Mocks
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Usage
```dart
final mockStorage = MockSecureStorageService();
when(mockStorage.read(key: 'api_key'))
    .thenAnswer((_) async => 'AIzaSyD...');

final manager = BYOKManagerImpl(secureStorage: mockStorage);
```

## Coverage Goals

- **Overall**: 80%+
- **Core Services**: 90%+
- **Crypto Services**: 95%+
- **UI Components**: 70%+

## Continuous Integration

Tests run automatically on:
- Pull requests
- Main branch commits
- Release tags

## Best Practices

1. **Test One Thing**: Each test should verify one behavior
2. **Clear Names**: Test names describe what is tested
3. **Arrange-Act-Assert**: Follow AAA pattern
4. **Mock External Dependencies**: Isolate unit under test
5. **Property Tests for Invariants**: Use glados for properties
6. **Clean Up**: Use tearDown for resource cleanup

## Related Documentation

- [Development Guidelines](../guidelines/development-guidelines.md) - Coding standards
- [AGENTS.md](../../AGENTS.md) - Testing workflow
- [Crypto Services](../core-services/crypto-services.md) - Security testing
