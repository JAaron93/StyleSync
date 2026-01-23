# StyleSync Documentation

Welcome to the StyleSync documentation! This comprehensive guide covers all aspects of the StyleSync Flutter application.

## Table of Contents

### Getting Started
- [Project Overview](./project/overview.md) - High-level introduction to StyleSync
- [Getting Started](./project/getting-started.md) - Setup and installation guide

### Architecture
- [Architecture Overview](./architecture/overview.md) - System design and architecture patterns

### Core Services
- [BYOK Manager](./core-services/byok-manager.md) - Bring Your Own Key system for API key management
- [Crypto Services](./core-services/crypto-services.md) - Encryption and key derivation services
- [Secure Storage Service](./core-services/secure-storage-service.md) - Platform-native secure storage
- [Onboarding Controller](./core-services/onboarding-controller.md) - Onboarding flow orchestration

### Features
- [Onboarding System](./features/onboarding/overview.md) - Complete onboarding flow documentation
  - [Onboarding Screen](./features/onboarding/onboarding-screen.md)
  - [Welcome Page](./features/onboarding/welcome-page.md)
  - [Tutorial Page](./features/onboarding/tutorial-page.md)
  - [API Key Input Page](./features/onboarding/api-key-input-page.md)
  - [Page Indicator](./features/onboarding/page-indicator.md)
- [API Key Management](./features/api-key-management.md) - API key lifecycle and validation
- [Cloud Backup Service](./features/cloud-backup-service.md) - Encrypted cloud backup system

### Platform Integration
- [Android Implementation](./platform/android.md) - Android-specific configuration and features
- [iOS Implementation](./platform/ios.md) - iOS-specific configuration and features
- [Web Implementation](./platform/web.md) - Web platform support

### Security
- [Security Overview](./security/overview.md) - Security implementation and best practices

### Testing
- [Testing Strategy](./testing/strategy.md) - Unit testing and property-based testing approach

### Development
- [Development Guidelines](./guidelines/development-guidelines.md) - Coding standards and best practices

### Reference
- [API Reference](./api/reference.md) - API documentation and references
- [Troubleshooting & FAQ](./troubleshooting/faq.md) - Common issues and solutions

## Quick Links

- **Source Code**: Located in `lib/` directory
- **Tests**: Located in `test/` directory
- **Platform Configurations**: `android/`, `ios/`, `web/`, etc.
- **Design Documents**: See individual service documentation for detailed design specs

## Contributing

When contributing to StyleSync:
1. Review the [Development Guidelines](./guidelines/development-guidelines.md)
2. Check the [Testing Strategy](./testing/strategy.md) for test requirements
3. Follow the [Security Overview](./security/overview.md) for security best practices

## Additional Resources

- **AGENTS.md**: Guidance for AI agents working on this project
- **Internal Design Docs**: See `lib/core/byok/byok_design.md` for detailed BYOK system design
- **Task Specs**: See `kiro_spec_manual_work/` for implementation plans and walkthroughs
