# Security Overview

## Security Architecture

StyleSync implements defense-in-depth security with multiple layers of protection for sensitive data.

## Key Security Principles

### 1. API Key Protection
- **No Logging**: API keys never logged, even in debug builds
- **Memory Protection**: Cleared immediately after use
- **Secure Storage**: Platform-native (Keychain/Keystore)
- **No Backend Transmission**: Keys never sent unencrypted

### 2. Encryption
- **Algorithm**: AES-256-GCM (authenticated encryption)
- **Key Size**: 256 bits
- **Nonce Management**: Unique 96-bit nonce per operation
- **MAC Verification**: Detects tampering

### 3. Key Derivation
- **Argon2id** (mobile): Memory-hard, GPU-resistant
  - 3 iterations
  - 64MB memory
  - 4 parallelism
- **PBKDF2** (web/fallback): 600,000 iterations, SHA-512
- **Unique Salts**: 16-byte random salt per derivation

### 4. Cloud Backup Security
- **Client-Side Encryption**: Data encrypted before upload
- **User-Controlled Passphrase**: Never stored
- **Atomic Operations**: Passphrase rotation is atomic
- **Firebase Security Rules**: Strict access control

## Threat Model

### Protected Against
- **Brute Force**: Memory-hard KDF
- **Tampering**: MAC verification
- **Unauthorized Access**: Platform secure storage
- **Man-in-the-Middle**: HTTPS, client-side encryption
- **Key Compromise**: Hardware isolation when available

### Out of Scope
- **Device Compromise**: Root/jailbreak can bypass security
- **Physical Access**: Device unlock grants app access
- **Supply Chain**: Assumes trusted dependencies

## Security Best Practices

### For Users
- Use strong passphrases for cloud backup
- Enable device encryption
- Keep device OS updated
- Don't share API keys

### For Developers
- Never log sensitive data
- Clear keys from memory after use
- Use hardware-backed storage when available
- Validate all inputs

## Compliance

### Standards
- **NIST SP 800-132**: PBKDF2 parameters
- **FIPS 140-2**: AES-GCM encryption
- **OWASP**: Key derivation iteration counts

### Privacy
- No telemetry without consent
- No server-side API key storage
- Minimal data collection

## Security Audit Points

### Critical Components
1. **Key Derivation Service**: Verify algorithm selection and parameters
2. **Encryption Service**: Check nonce uniqueness and MAC verification
3. **Secure Storage**: Validate platform configuration
4. **Cloud Backup**: Review passphrase rotation atomicity
5. **API Key Validator**: Check rate limiting and timeouts

## Incident Response

### If API Key Compromised
1. User deletes key from app
2. User revokes key in Google Cloud Console
3. User generates new API key
4. User adds new key to app

### If Backup Passphrase Compromised
1. User rotates passphrase in app
2. Old backups become inaccessible
3. New backup created with new passphrase

## Related Documentation

- [Crypto Services](../core-services/crypto-services.md) - Encryption details
- [Secure Storage](../core-services/secure-storage-service.md) - Storage security
- [BYOK Manager](../core-services/byok-manager.md) - Key management
- [Cloud Backup Service](../features/cloud-backup-service.md) - Backup security
