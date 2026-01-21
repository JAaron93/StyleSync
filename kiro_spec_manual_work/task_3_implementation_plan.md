# Implementation Plan - Key Derivation and Encryption Services

Implement high-security cryptographic services to support API key management (BYOK) and secure cloud backups.

## Proposed Changes

### [Component] Cryptography Layer
Establish the foundation for key derivation and encryption using industry-standard algorithms.

#### [NEW] [key_derivation_service.dart](file:///Users/pretermodernist/StyleSync/lib/core/crypto/key_derivation_service.dart)
- Define `KeyDerivationService` interface.
- Implement `KeyDerivationServiceImpl` with:
    - **Argon2id** for non-web platforms (3 iterations, 64MB memory, 4 parallelism).
    - **PBKDF2** for web platform or fallback (600,000 iterations, SHA-512).
- Support for generating 32-byte salts.

#### [NEW] [encryption_service.dart](file:///Users/pretermodernist/StyleSync/lib/core/crypto/encryption_service.dart)
- Define `EncryptionService` interface.
- Implement `AESGCMEncryptionService` using `AES-256-GCM`.
- Handle 96-bit nonces (prepending to ciphertext).
- Implement nonce reuse prevention (via random nonces for distinct keys).

#### [NEW] [kdf_metadata.dart](file:///Users/pretermodernist/StyleSync/lib/core/crypto/kdf_metadata.dart)
- Model to store KDF parameters and salt for later key regeneration during decryption.

---

## Verification Plan

### Automated Tests
- **Unit Tests**:
    - `test/key_derivation_service_test.dart`: Verify Argon2id and PBKDF2 outputs with known test vectors.
    - `test/encryption_service_test.dart`: Verify AES-GCM encryption/decryption round-trip.
- **Property Tests (Glados)**:
    - `test/crypto_properties_test.dart`: 
        - **Property 3**: Cloud Backup Encryption Round-Trip (any plaintext -> encrypt -> decrypt == original).
        - **Property 23**: KDF Consistency (same input + params -> same key).

### Manual Verification
- Log KDF time on real devices to ensure performance is within acceptable bounds (Argon2id should take ~0.5-1s).
