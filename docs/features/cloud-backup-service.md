# Cloud Backup Service

## Overview

The Cloud Backup Service provides encrypted cloud backup for API keys using Firebase Storage. All encryption happens client-side, and backups are protected by user-controlled passphrases.

## Key Features

- **Client-Side Encryption**: Data encrypted before upload
- **Passphrase-Based**: User controls encryption passphrase
- **Atomic Operations**: Rotation and uploads are atomic
- **Firebase Storage**: Secure cloud storage with strict security rules

## Implementation

See [BYOK Manager - CloudBackupService section](../core-services/byok-manager.md#cloudbackupservice) for complete implementation details.

## Operations

### Create/Update Backup
1. Derive encryption key from passphrase (Argon2id/PBKDF2)
2. Encrypt API key config (AES-256-GCM)
3. Upload to Firebase Storage at `users/{userId}/api_key_backup.json`

### Restore Backup
1. Download encrypted backup from Firebase
2. Derive decryption key from passphrase
3. Decrypt and validate
4. Store locally

### Passphrase Rotation
1. Download backup
2. Decrypt with old passphrase
3. Re-encrypt with new passphrase
4. Atomic upload/rename
5. Rollback on failure

### Delete Backup
Remove backup file from Firebase Storage

## Security

### Encryption
- **Algorithm**: AES-256-GCM
- **Key Derivation**: Argon2id (mobile) or PBKDF2 (web)
- **Salt**: Unique 16-byte random salt per backup
- **Nonce**: Unique 12-byte nonce per encryption

### Access Control
Firebase Storage security rules ensure:
- Users can only access their own backups
- Authentication required
- No empty file overwrites

### Passphrase Protection
- Never stored locally or on server
- Only used for key derivation
- Cleared from memory after use

## Backup Format

```json
{
  "version": 1,
  "kdf": {
    "algorithm": "argon2id",
    "salt": "base64_encoded_salt",
    "iterations": 3,
    "memory": 65536,
    "parallelism": 4
  },
  "encrypted_data": "base64_encoded_encrypted_config",
  "created_at": "2025-01-21T22:00:00.000Z",
  "updated_at": "2025-01-21T22:00:00.000Z"
}
```

## Related Documentation

- [BYOK Manager](../core-services/byok-manager.md) - Complete implementation
- [Crypto Services](../core-services/crypto-services.md) - Encryption details
- [Security Overview](../security/overview.md) - Security architecture
