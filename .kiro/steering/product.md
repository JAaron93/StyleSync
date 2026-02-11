# Product Overview

StyleSync is a Flutter application for managing Vertex AI API keys with secure storage and encrypted cloud backup.

## Core Value Proposition
- Secure API key management using platform-native secure storage (iOS Keychain, Android Keystore)
- Client-side encrypted cloud backup with user-controlled passphrases
- Cross-platform support (Android, iOS, Web, macOS, Linux, Windows)

## Key Features
- **Secure Storage**: Hardware-backed secure storage where available, software fallback
- **Encryption**: AES-256-GCM encryption with Argon2id/PBKDF2 key derivation
- **Cloud Backup**: Firebase-based encrypted backup with user passphrase protection
- **Onboarding**: User-friendly setup flow for API key configuration

## Security Focus
This is a security-critical application. All code changes must prioritize:
- Cryptographic correctness
- Secure key handling
- Protection of user credentials
- Proper error handling that doesn't leak sensitive information
