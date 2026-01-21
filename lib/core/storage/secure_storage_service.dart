import 'dart:async';

/// Possible backends for secure storage, prioritized by security level.
enum SecureStorageBackend {
  /// Android StrongBox Keymaster (highest security, hardware-isolated)
  strongBox,

  /// TEE-backed storage (TrustZone on Android, Secure Enclave on iOS)
  hardwareBacked,

  /// Software-backed secure storage (fallback)
  software,
}

/// Interface for platform-native secure storage.
abstract class SecureStorageService {
  /// Writes [value] to secure storage with [key].
  Future<void> write(String key, String value);

  /// Reads [value] from secure storage for [key].
  Future<String?> read(String key);

  /// Deletes [key] and its associated value from secure storage.
  Future<void> delete(String key);

  /// Clears all entries from secure storage.
  Future<void> deleteAll();

  /// Returns the current storage backend in use.
  SecureStorageBackend get backend;

  /// Returns true if the storage requires biometric/device-passcode to access.
  bool get requiresBiometric;
}
