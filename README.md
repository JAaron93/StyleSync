# StyleSync

A Flutter application for managing Vertex AI API keys with secure storage and encrypted cloud backup.

## Quick Start

### Prerequisites
- **Flutter SDK**: `^3.11.4`
- **Dart SDK**: Compatible with Flutter version
- **Homebrew** (optional, for macOS installation)

### Installation

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Documentation

📚 **[Complete Documentation](./docs/)** - Comprehensive guides and references

### Quick Links
- [Project Overview](./docs/project/overview.md) - What is StyleSync?
- [Getting Started Guide](./docs/project/getting-started.md) - Detailed setup instructions
- [Architecture Overview](./docs/architecture/overview.md) - System design
- [Development Guidelines](./docs/guidelines/development-guidelines.md) - Coding standards
- [Testing Strategy](./docs/testing/strategy.md) - Testing approach
- [Troubleshooting & FAQ](./docs/troubleshooting/faq.md) - Common issues

## Key Features

- ✅ **Digital Closet & Clothing Management** - Organize your wardrobe with background removal and auto-tagging
- ✅ **Bring Your Own Key (BYOK) Management** - Securely manage personal Vertex AI API keys
- ☁️ **Encrypted Cloud Backup** - Client-side encryption with user-controlled passphrase
- 🔒 **Strong Cryptography** - AES-256-GCM encryption, Argon2id/PBKDF2 key derivation
- ✅ **Comprehensive Testing** - Unit tests, manual fakes, and property-based testing with Glados
- 📱 **Cross-Platform** - Android, iOS, Web, macOS, Linux, Windows

## Development

### Common Commands

```bash
# Run tests
flutter test

# Format code
dart format .

# Analyze code
flutter analyze

# Generate code (mocks, etc.)
dart run build_runner build --delete-conflicting-outputs
```

### Development Environment

#### Gradle Configuration (Android)
Optimized settings in `android/gradle.properties`:
- `org.gradle.jvmargs`: `-Xmx4G` for balanced performance
- `org.gradle.parallel`: Enabled for faster builds
- `org.gradle.caching`: Enabled to reuse build artifacts

## Project Structure

```
lib/
├── core/              # Core services and infrastructure
│   ├── byok/         # API key management
│   ├── crypto/       # Encryption and key derivation
│   ├── onboarding/   # Onboarding controller
│   └── storage/      # Secure storage service
├── features/         # Feature implementations
│   └── onboarding/   # Onboarding UI
└── main.dart         # App entry point

test/                 # Test suites
├── core/            # Core service tests
├── features/        # Feature tests
└── *_test.dart      # Unit and property tests

docs/                # Documentation
```

## Contributing

Before contributing:
1. Read [Development Guidelines](./docs/guidelines/development-guidelines.md)
2. Check [Testing Strategy](./docs/testing/strategy.md)
3. Review [Architecture Overview](./docs/architecture/overview.md)

## Additional Resources

- **[docs/](./docs/)** - Complete documentation hub
- **Design Specs** - See `lib/core/byok/byok_design.md` and `plans/`
