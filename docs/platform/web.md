# Web Implementation

## Configuration

### Platform Detection

Web platform uses feature detection for cryptography algorithms:

- **Key Derivation**: PBKDF2 (Argon2id not available in browsers)
- **Encryption**: AES-256-GCM (via Web Crypto API)

### Firebase Configuration

Firebase automatically configured for web via FlutterFire CLI.

## Platform-Specific Features

### Cryptography
- **PBKDF2**: 600,000 iterations with SHA-512
- **Web Crypto API**: Browser-native crypto operations
- **No Argon2id**: Falls back to PBKDF2

### Storage
- **IndexedDB**: flutter_secure_storage uses IndexedDB on web
- **Software Encryption**: No hardware-backed storage

## Build Commands

```bash
# Debug build
flutter run -d chrome

# Release build
flutter build web --release

# Serve locally
flutter run -d web-server --web-port=8080
```

## Deployment

Build output in `build/web/` can be deployed to:
- Firebase Hosting
- Netlify
- Vercel
- Any static hosting service

## Limitations

- No hardware-backed secure storage
- PBKDF2 instead of Argon2id (slower key derivation)
- No Secure Enclave/Keystore equivalent

## Related Documentation

- [Getting Started](../project/getting-started.md) - Setup guide
- [Crypto Services](../core-services/crypto-services.md) - PBKDF2 details
