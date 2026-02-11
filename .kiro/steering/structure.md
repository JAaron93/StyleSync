# Project Structure

## Directory Organization

```
lib/
├── core/              # Core services and infrastructure
│   ├── byok/         # Bring Your Own Key (API key management)
│   ├── crypto/       # Encryption, key derivation services
│   ├── onboarding/   # Onboarding controller logic
│   └── storage/      # Secure storage service (hardware/software backed)
├── features/         # Feature implementations (UI + feature-specific logic)
│   └── onboarding/   # Onboarding screens and widgets
└── main.dart         # Application entry point

test/                 # Test suites (mirrors lib/ structure)
├── core/            # Tests for core services
├── features/        # Tests for features
└── *_test.dart      # Unit tests
└── *_properties_test.dart  # Property-based tests

docs/                # Documentation
├── api/             # API reference
├── architecture/    # System design docs
├── core-services/   # Service-specific documentation
├── features/        # Feature documentation
├── guidelines/      # Development standards
├── platform/        # Platform-specific guides
├── security/        # Security documentation
└── testing/         # Testing strategy

android/             # Android platform code
ios/                 # iOS platform code
web/                 # Web platform code
```

## Code Organization Principles

### Core vs Features
- **`lib/core/`**: Reusable services, infrastructure, business logic
- **`lib/features/`**: UI components and feature-specific implementations

### Testing Structure
- Test files mirror the `lib/` structure
- Unit tests: `*_test.dart`
- Property-based tests: `*_properties_test.dart` or `*_property_test.dart`
- Mocks generated via Mockito in test files

### State Management
- Riverpod providers for dependency injection and state
- Providers should be defined close to where they're used
- Global providers in appropriate core service files

## File Naming Conventions
- Dart files: `snake_case.dart`
- Test files: `snake_case_test.dart`
- Property test files: `snake_case_properties_test.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
