# API Key Management

## Overview

StyleSync's API key management system allows users to bring their own Vertex AI API keys, validate them, and securely store them locally with optional encrypted cloud backup.

## Components

See [BYOK Manager](../core-services/byok-manager.md) for detailed implementation.

## Key Features

### Validation Pipeline
1. **Format Validation**: Checks key structure (AIza prefix, 39 characters)
2. **Functional Validation**: Tests key with actual API call
3. **Rate Limiting**: Prevents validation abuse

### Secure Storage
- Platform-native secure storage (Keychain/Keystore)
- Hardware-backed encryption when available
- No plaintext storage

### Cloud Backup (Optional)
- Client-side encryption before upload
- User-controlled passphrase
- Atomic passphrase rotation
- See [Cloud Backup Service](./cloud-backup-service.md)

## Usage Flow

```
User Input → Format Check → API Test → Secure Storage → Cloud Backup (Optional)
```

## Related Documentation

- [BYOK Manager](../core-services/byok-manager.md) - Complete implementation details
- [Secure Storage](../core-services/secure-storage-service.md) - Storage mechanism
- [Cloud Backup Service](./cloud-backup-service.md) - Backup functionality
- [API Key Input Page](./onboarding/api-key-input-page.md) - UI component
